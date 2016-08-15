//
//  MXProtocolImpl.m
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "MXProtocolImpl.h"
#import <objc/runtime.h>
#import "MXMethodDescription.h"
#import "MXDataConverterFactory.h"
#import <AFNetworking/AFNetworking.h>

NSString* const MXHTTPErrorDomain = @"com.meixin.engine.httpErrorDomain";

typedef void (^MXRequestSuccessCallback)(id result, NSURLResponse *response);
typedef void (^MXRequestFailCallback)(NSString *errorMessage, NSURLResponse *response, NSError* error);

@implementation MXProtocolImpl

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    struct objc_method_description desc = protocol_getMethodDescription(self.protocol, anInvocation.selector, YES, YES);
    
    if (desc.name == NULL && desc.types == NULL) {
        [super forwardInvocation:anInvocation];
    } else {
        [self handleInvocation:anInvocation];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    struct objc_method_description desc = protocol_getMethodDescription(self.protocol, aSelector, YES, YES);
    
    if (desc.name == NULL && desc.types == NULL) {
        return [super respondsToSelector:aSelector];
    } else {
        return YES;
    }
}

- (void)cleanupInvocation:(NSInvocation*)invocation callingError:(NSError*)error callback:(MXRequestFailCallback)callback
{
    id nilReturn = nil;
    [invocation setReturnValue:&nilReturn];
    
    [self.urlSession.delegateQueue addOperationWithBlock:^{
        callback(nil, nil, error);
    }];
}

- (void)handleInvocation:(NSInvocation*)invocation
{
    [invocation retainArguments];
    
    // track which parameters have been used
    NSMutableSet* consumedParameters = [[NSMutableSet alloc] init];
    
    // get method description
    NSString* sig = NSStringFromSelector(invocation.selector);
    MXMethodDescription* desc = self.methodDescriptions[sig];
    NSLog(@"you called '%@', which has the description:\n%@", sig, desc);
    
    NSAssert(desc.resultType != nil, @"Callback not defined for %@", sig);
    
    // get the fail callback
    __unsafe_unretained MXRequestFailCallback failCallbackArg;
    NSUInteger numArgs = [invocation.methodSignature numberOfArguments];
    [invocation getArgument:&failCallbackArg atIndex:(numArgs - 1)];
    // must copy to heap
    MXRequestFailCallback failCallback = [failCallbackArg copy];
    
    // get the success callback
    __unsafe_unretained MXRequestSuccessCallback successCallbackArg;
    [invocation getArgument:&successCallbackArg atIndex:(numArgs - 2)];
    // must copy to heap
    MXRequestSuccessCallback successCallback = [successCallbackArg copy];
    
    
    // construct path
    NSError* error = nil;
    id<MXDataConverter> converter = [self.converterFactory converter];
    MXParameterizeResult<NSString*>* pathParamResult = [desc parameterizedPathForInvocation:invocation
                                                                              withConverter:converter
                                                                                      error:&error];
    NSLog(@"%@",pathParamResult.result);
    NSLog(@"%@",pathParamResult.consumedParameters);
    if (error) {
        [self cleanupInvocation:invocation callingError:error callback:failCallback];
        return;
    }
    
    NSURL* fullPath = [self.endPoint URLByAppendingPathComponent:pathParamResult.result];
    [consumedParameters unionSet:pathParamResult.consumedParameters];
    
    NSLog(@"full path: %@", fullPath);
    
    // construct request
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:fullPath];
    request.HTTPMethod = [desc httpMethod];
    
    // get body
    MXParameterizeResult* bodyParamResult = [desc bodyForInvocation:invocation withConverter:converter error:&error];
    
    if (error) {
        [self cleanupInvocation:invocation callingError:error callback:failCallback];
        return;
    }
    
    id bodyObj = bodyParamResult.result;
    [consumedParameters unionSet:bodyParamResult.consumedParameters];
    
    // set headers
    MXParameterizeResult<NSDictionary*>* headerParamResult = [desc parameterizedHeadersForInvocation:invocation
                                                                                       withConverter:converter
                                                                                               error:&error];
    
    if (error) {
        [self cleanupInvocation:invocation callingError:error callback:failCallback];
        return;
    }
    
    for (NSString* key in headerParamResult.result) {
        [request setValue:headerParamResult.result[key] forHTTPHeaderField:key];
    }
    
    [consumedParameters unionSet:headerParamResult.consumedParameters];
    
    // finally, leftover parameters go in the query (or form-url-encoded body)
    NSMutableSet* queryParams = [NSMutableSet setWithArray:desc.parameterNames];
    [queryParams minusSet:consumedParameters];
    
    if ([desc isFormURLEncoded]) {
        
        NSAssert(bodyObj == nil, @"FormURLEncoding and an explicit Body object are mutually exclusive");
        
        // for FormURLEncoding, put extra params in body instead of URL query
        
        // I guess don't override this if the user set it explicitly
        if (![request valueForHTTPHeaderField:@"Content-Type"]) {
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        
        // compose the form body
        NSArray* formItems = [self queryItemsForParameters:queryParams
                                         methodDescription:desc
                                                invocation:invocation
                                                 converter:converter
                                                     error:&error];
        
        if (error) {
            [self cleanupInvocation:invocation callingError:error callback:failCallback];
            return;
        } else {
            // let's slightly abuse this to construct the url encoded body
            NSURLComponents* urlComps = [NSURLComponents componentsWithURL:self.endPoint resolvingAgainstBaseURL:false];
            urlComps.queryItems = formItems;
            NSURL* url = urlComps.URL;
            NSString* bodyString = url.query;
            bodyObj = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        }
        
    } else if (queryParams.count > 0) {
        NSURLComponents* urlComps = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
        NSMutableArray* queryItems = urlComps.queryItems.mutableCopy;
        
        NSArray* otherQueryItems = [self queryItemsForParameters:queryParams
                                               methodDescription:desc
                                                      invocation:invocation
                                                       converter:converter
                                                           error:&error];
        
        if (error) {
            [self cleanupInvocation:invocation callingError:error callback:failCallback];
            return;
        } else if (otherQueryItems) {
            if (queryItems) {
                [queryItems addObjectsFromArray:otherQueryItems];
            } else {
                queryItems = otherQueryItems.mutableCopy;
            }
        }
        
        urlComps.queryItems = queryItems;
        request.URL = urlComps.URL;
    }
    
    // we'll set this here in case it's not an upload task
    if ([bodyObj isKindOfClass:[NSData class]]) {
        request.HTTPBody = bodyObj;
    } else if ([bodyObj isKindOfClass:[NSInputStream class]]) {
        request.HTTPBodyStream = bodyObj;
    }
    
    Class taskClass = [desc taskClass];
    NSAssert(taskClass != nil, @"could not determine session task type");
    
    
    NSURLSessionTask* task = nil;
    AFHTTPSessionManager *httpSessionManager = [AFHTTPSessionManager manager];
    //https 证书验证
//    NSString * cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];
//    NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
//    NSLog(@"%@", cerData);
//    httpSessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[[NSSet alloc] initWithObjects:cerData, nil]];
    httpSessionManager.securityPolicy.allowInvalidCertificates = YES;
    [httpSessionManager.securityPolicy setValidatesDomainName:NO];
    
#ifdef DEBUG
    httpSessionManager.requestSerializer.timeoutInterval = 3.0f;
#else
    httpSessionManager.requestSerializer.timeoutInterval = 20.0f;
#endif
    
    httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    
    
    // somewhat complicated construction of correct task and setting of body
    if (taskClass == [NSURLSessionDownloadTask class]) {
        // if they provided a URL for the body, assume it is a local file and make a stream
        if ([bodyObj isKindOfClass:[NSURL class]]) {
            request.HTTPBodyStream = [NSInputStream inputStreamWithURL:bodyObj];
        }
        
//        task = [self.urlSession downloadTaskWithRequest:request completionHandler:callback];
//        task = [httpSessionManager downloadTaskWithRequest:request progress:nil destination:nil completionHandler:callback];
    } else {
        void (^completionHandler)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) =
        ^(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) {
            //log reponse
            NSLog(@"%@",responseObject);
            
            id result = nil;
            
            if (!error) {
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                
                if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
                    
                    if ([converter respondsToSelector:@selector(convertErrorData:forResponse:)]) {
                        error = [converter convertErrorData:responseObject forResponse:httpResponse];
                    }
                    
                    if (!error) {
                        NSDictionary* userInfo = nil;
                        
//                        if (data) {
//                            NSString* errorMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                            
//                            if (errorMessage) {
//                                userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
//                            }
//                        }
//                        
//                        error = [NSError errorWithDomain:MXHTTPErrorDomain code:httpResponse.statusCode userInfo:userInfo];
                    }else{
                        result = error.description;
                    }
                    //http fail
                    failCallback(result,response,error);
                }else{
                    //http success
                    Class type = [desc resultConversionClass];
                    //data convert todo franklin
                    result = [converter convertData:responseObject toObjectOfClass:type error:&error];
                    successCallback(result,response);
                    
                }
            }
            else{
                //error converter
                
                //fail callback
                failCallback(result,response,error);
            }
            
//            callback(result, response, error);
        };
        
        if (taskClass == [NSURLSessionDataTask class]) {
            // if they provided a URL for the body, assume it is a local file and make a stream
            if ([bodyObj isKindOfClass:[NSURL class]]) {
                request.HTTPBodyStream = [NSInputStream inputStreamWithURL:bodyObj];
            }
            
//            task = [self.urlSession dataTaskWithRequest:request
//                                      completionHandler:completionHandler];
            task = [httpSessionManager dataTaskWithRequest:request completionHandler:completionHandler];
        } else {
//            if ([bodyObj isKindOfClass:[NSData class]]) {
//                task = [self.urlSession uploadTaskWithRequest:request
//                                                     fromData:bodyObj
//                                            completionHandler:completionHandler];
//            } else if ([bodyObj isKindOfClass:[NSURL class]]) {
//                task = [self.urlSession uploadTaskWithRequest:request
//                                                     fromFile:bodyObj
//                                            completionHandler:completionHandler];
//            }
        }
    }
    [task resume];
    [invocation setReturnValue:&task];
}

- (NSArray*)queryItemsForParameters:(NSSet*)queryParameters
                  methodDescription:(MXMethodDescription*)methodDescription
                         invocation:(NSInvocation*)invocation
                          converter:(id<MXDataConverter>)converter
                              error:(NSError**)error
{
    NSMutableArray* queryItems = [[NSMutableArray alloc] init];
    
    
    for (NSString* paramName in queryParameters) {
        
        NSUInteger paramIdx = [methodDescription.parameterNames indexOfObject:paramName];
        NSString* value = [methodDescription stringValueForParameterAtIndex:paramIdx
                                                             withInvocation:invocation
                                                                  converter:converter
                                                                      error:error];
        
        if (error && *error) {
            return nil;
        }
        
        [queryItems addObject:[[NSURLQueryItem alloc] initWithName:paramName value:value]];
    }
    
    return queryItems;
}

@end
