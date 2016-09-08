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
#import "MXWebClient.h"

typedef enum {
    MXFormData,
    MXFormUrlencode,
    MXFormRaw,
}MXHttpBodyFormType;

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
    
    [MXWebClientInstance.session.delegateQueue addOperationWithBlock:^{
        callback(nil, nil, error);
    }];
}

- (void)handleInvocation:(NSInvocation*)invocation
{
    [invocation retainArguments];
    
    // get method description
    NSString* sig = NSStringFromSelector(invocation.selector);
    MXMethodDescription* desc = self.methodDescriptions[sig];
    NSLog(@"you called '%@', which has the description:\n%@", sig, desc);
    
    NSAssert(desc.resultType != nil, @"Callback not defined for %@", sig);
    NSParameterAssert(desc.httpMethod);
    
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
    
    // get body
    MXParameterizeResult* bodyParamResult = [desc bodyForInvocation:invocation withConverter:converter error:&error];
    if (error) {
        [self cleanupInvocation:invocation callingError:error callback:failCallback];
        return;
    }
    
    // set headers
    MXParameterizeResult<NSDictionary*>* headerParamResult = [desc parameterizedHeadersForInvocation:invocation
                                                                                       withConverter:converter
                                                                                               error:&error];
    if (error) {
        [self cleanupInvocation:invocation callingError:error callback:failCallback];
        return;
    }
    
    // track which parameters have been used
    NSMutableSet* consumedParameters = [[NSMutableSet alloc] init];
    [consumedParameters unionSet:pathParamResult.consumedParameters];
    [consumedParameters unionSet:bodyParamResult.consumedParameters];
    [consumedParameters unionSet:headerParamResult.consumedParameters];
    
    // finally, leftover parameters go in the query (or form-url-encoded body)
    NSMutableSet* queryParams = [NSMutableSet setWithArray:desc.parameterNames];
    [queryParams minusSet:consumedParameters];
    
    NSDictionary* queryItems = [self queryItemsForParameters:queryParams
                                           methodDescription:desc
                                                  invocation:invocation
                                                   converter:converter
                                                       error:&error];
    if (error) {
        [self cleanupInvocation:invocation callingError:error callback:failCallback];
        return;
    }
    
    
    NSMutableURLRequest *request = nil;
    NSURLSessionTask* task = nil;
    
    Class taskClass = [desc taskClass];
    NSAssert(taskClass != nil, @"could not determine session task type");
    id bodyObj = bodyParamResult.result;
    // somewhat complicated construction of correct task and setting of body
    if (taskClass == [NSURLSessionDownloadTask class]) {
        request = [self generateDownloadRequest];
        // if they provided a URL for the body, assume it is a local file and make a stream
        if ([bodyObj isKindOfClass:[NSURL class]]) {
            request.HTTPBodyStream = [NSInputStream inputStreamWithURL:bodyObj];
        }
        
        //        task = [self.urlSession downloadTaskWithRequest:request completionHandler:callback];
        //        task = [httpSessionManager downloadTaskWithRequest:request progress:nil destination:nil completionHandler:callback];
    } else {
        MXHttpBodyFormType bodyFormType = MXFormData ;
        if(desc.isFormURLEncoded)
            bodyFormType = MXFormUrlencode;
        
        request = [self generateRequest:desc.httpMethod path:pathParamResult header:headerParamResult body:bodyParamResult queryItems:queryItems httpBodyFormType:bodyFormType];
        void (^completionHandler)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) =
        ^(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) {
            //log reponse
#if DEBUG
            if(error){
                NSLog(@"%@",error.description);
            }else{
                NSString *responseDesc = [responseObject description];
                responseDesc = [NSString stringWithCString:[responseDesc cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
                if(responseDesc){
                    NSLog(@"%@",responseDesc);
                }else{
                    NSLog(@"%@",responseObject);
                }
            }
#endif
            
            id result = nil;
            
            if (!error) {
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                
                if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
                    
                    if ([converter respondsToSelector:@selector(convertErrorData:forResponse:)]) {
                        error = [converter convertErrorData:responseObject forResponse:httpResponse];
                    }
                    
                    if (!error) {
                        NSDictionary* userInfo = nil;
                        
                        if (responseObject) {
                            NSString* errorMessage = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                            
                            if (errorMessage) {
                                userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
                            }
                        }
                        
                        error = [NSError errorWithDomain:MXHTTPErrorDomain code:httpResponse.statusCode userInfo:userInfo];
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
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                //error converter
                result = [converter convertError:error forResponse:httpResponse];
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
            
            task = [MXWebClientInstance dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
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

- (NSDictionary *)queryItemsForParameters:(NSSet*)queryParameters
                        methodDescription:(MXMethodDescription*)methodDescription
                               invocation:(NSInvocation*)invocation
                                converter:(id<MXDataConverter>)converter
                                    error:(NSError**)error
{
    NSMutableDictionary* queryItems = [[NSMutableDictionary alloc] init];
    //    //add public params
    //    NSDictionary *pulicParamsDic = [[MXWebClientInstance.publicParamsFactory pubicParamsDelegate] pubicParams];
    //    for(NSString *key in pulicParamsDic.allKeys){
    //        id obj = [pulicParamsDic objectForKey:key];
    //        if([obj isKindOfClass:[NSNumber class]]){
    //            [queryItems addObject:[[NSURLQueryItem alloc] initWithName:key value:[obj stringValue]]];
    //        }else{
    //            [queryItems addObject:[[NSURLQueryItem alloc] initWithName:key value:obj]];
    //        }
    //    }
    
    for (NSString* paramName in queryParameters) {
        
        NSUInteger paramIdx = [methodDescription.parameterNames indexOfObject:paramName];
        NSString* value = [methodDescription stringValueForParameterAtIndex:paramIdx
                                                             withInvocation:invocation
                                                                  converter:converter
                                                                      error:error];
        
        if (error && *error) {
            return nil;
        }
        
        [queryItems setObject:value forKey:paramName];
    }
    
    return queryItems;
}

- (void)setHeaderTorequest:(NSMutableURLRequest *)request flag:(BOOL)flag error:(NSError *)error headerParams:(NSDictionary *)headerParams{
    NSAssert(error==nil,@"generate http request failed : %@",error);
    NSLog(@"headerParams:%@",headerParams);
    [headerParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![key isEqualToString:@"Content-Type"] || flag) {
            [request setValue:[obj isKindOfClass:[NSNumber class]]?((NSNumber*)obj).stringValue:obj forHTTPHeaderField:key];
        }
    }];
    
}

#pragma mark - request generate methods
//TODO: download file and backgournd upload file
-(NSMutableURLRequest *)generateRequest:(NSString *)httpMethod
                                   path:(MXParameterizeResult<NSString*>*)pathParamResult
                                 header:(MXParameterizeResult<NSDictionary*>*)headerParamResult
                                   body:(MXParameterizeResult*)bodyParamResult
                             queryItems:(NSDictionary*)queryItems
                       httpBodyFormType:(MXHttpBodyFormType)httpBodyFormType{
    
    NSMutableDictionary *headerParams = [NSMutableDictionary dictionaryWithDictionary:headerParamResult.result];
    //    if(self.publicParamsType == MXPublicParamsInPath){
    //        [headerParams setDictionary:[[MXWebClientInstance.publicParamsFactory pubicParamsDelegate] pubicParams]];
    //        
    //    }else if (self.publicParamsType == MXPublicParamsInHeader){
    if(self.publicParamsDic.count>0){//request custom
        [headerParams setValuesForKeysWithDictionary:self.publicParamsDic];
    }else{
        [headerParams setValuesForKeysWithDictionary:[[MXWebClientInstance.publicParamsFactory pubicParamsDelegate] pubicParams]];
    }
    //    }
    
    NSURL* fullPath = [self.endPoint URLByAppendingPathComponent:pathParamResult.result];
    NSLog(@"full path: %@", fullPath);
    NSMutableURLRequest* request = nil;//[[NSMutableURLRequest alloc] initWithURL:fullPath];
//    request.HTTPMethod = httpMethod;
    
    NSError *error = nil;
    //#define SET_HEAD_TO_REQUEST(flag)  if(error){ \
    //NSAssert(false,@"generate http request failed : %@",error); \
    //return nil;\
    //}\
    //[headerParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {\
    //if (![key isEqualToString:@"Content-Type"] || flag) {\
    //[request setValue:[obj isKindOfClass:[NSNumber class]]?((NSNumber*)obj).stringValue:obj forHTTPHeaderField:key];\
    //}\
    //}]
    if([httpMethod isEqualToString:@"GET"] ||
       [httpMethod isEqualToString:@"DELETE"] ||
       [httpMethod isEqualToString:@"HEAD"]){
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:queryItems];
        [params setValuesForKeysWithDictionary:headerParams];
        request = [MXWebClientInstance.requestSerializer requestWithMethod:httpMethod URLString:[fullPath relativeString] parameters:params error:&error];
        //        SET_HEAD_TO_REQUEST(NO);
        return request;
    }else{
        id bodyObj = bodyParamResult.result;
        if(!bodyObj){
            bodyObj = queryItems;
        }
        //        else if ([bodyObj isKindOfClass:[NSDictionary class]]){
        //            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:bodyObj];
        //            [dic setValuesForKeysWithDictionary:bodyParamResult.result];
        //            [dic setValuesForKeysWithDictionary:headerParams];
        //            bodyObj = dic;
        //        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:bodyObj];
        [params setValuesForKeysWithDictionary:bodyParamResult.result];
        //        [params setValuesForKeysWithDictionary:headerParams];
        if(self.publicParamsType==MXPublicParamsInPath){
            [params setValuesForKeysWithDictionary:headerParams];
            
            NSURLComponents* urlComps = [NSURLComponents componentsWithURL:fullPath resolvingAgainstBaseURL:NO];
            NSMutableArray* queryItems = urlComps.queryItems.mutableCopy;
            
            NSMutableArray* queryItemsArray = [[NSMutableArray alloc] init];
            //add public params
            for(NSString *key in params.allKeys){
                id obj = [params objectForKey:key];
                if([obj isKindOfClass:[NSNumber class]]){
                    [queryItemsArray addObject:[[NSURLQueryItem alloc] initWithName:key value:[obj stringValue]]];
                }else{
                    [queryItemsArray addObject:[[NSURLQueryItem alloc] initWithName:key value:obj]];
                }
            }
            
            if (queryItems) {
                [queryItems addObjectsFromArray:queryItemsArray];
            } else {
                queryItems = queryItemsArray.mutableCopy;
            }
            request = [MXWebClientInstance.requestSerializer requestWithMethod:httpMethod
                                                                     URLString:[fullPath absoluteString]
                                                                    parameters:params
                                                                         error:&error];
            urlComps.queryItems = queryItems;
            request.URL = urlComps.URL;
            return request;
        }else{//add to header
//            [self setHeaderTorequest:request flag:YES error:error headerParams:headerParams];
        }
        switch (httpBodyFormType) {
            case MXFormData:{
                //                request = [self generateFormDataRequest:httpMethod
                //                                               fullPath:[fullPath absoluteString]
                //                                             parameters:bodyObj
                //                                                  error:&error];
                request = [MXWebClientInstance.requestSerializer requestWithMethod:httpMethod
                                                                         URLString:[[NSURL URLWithString:[fullPath absoluteString] relativeToURL:self.endPoint] absoluteString]
                                                                        parameters:params
                                                                             error:&error];
                 [self setHeaderTorequest:request flag:YES error:error headerParams:headerParams];
                //                SET_HEAD_TO_REQUEST(YES);
                //                                [self setHeaderTorequest:request flag:YES error:error headerParams:params];
                break;
            }
            case MXFormUrlencode:{
                request = [MXWebClientInstance.requestSerializer requestWithMethod:httpMethod
                                                                         URLString:[fullPath absoluteString]
                                                                        parameters:bodyObj
                                                                             error:&error];
                //                SET_HEAD_TO_REQUEST(YES);
                break;
            }
            case MXFormRaw:{
                //                request = [self generateRawDataRequest:requestSerializer
                //                                                  path:path
                //                                            parameters:parameters
                //                                            annotation:methodAnnotation
                //                                                 error:error];
                //                SET_HEAD_TO_REQUEST(YES);
                break;
            }
            default:
                break;
        }
    }
    
    
    return request;
    
}

//-(NSMutableURLRequest *)generateFormDataRequest:(NSString *)httpMethod
//                                       fullPath:(NSString *)fullPath
//                                     parameters:(NSDictionary *)parameters
//                                          error:(NSError **)error{
//    return [MXWebClientInstance.requestSerializer multipartFormRequestWithMethod:httpMethod
//                                                                       URLString:fullPath
//                                                                      parameters:nil
//                                                       constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//                                                           if([parameters isKindOfClass:[NSDictionary class]]){
//                                                               for(NSString *key in [parameters allKeys]){
//                                                                   if([parameters[key] isKindOfClass:[NSString class]]){
//                                                                       [formData appendPartWithFormData:[parameters[key] dataUsingEncoding:NSUTF8StringEncoding]
//                                                                                                   name:key];
//                                                                   }else if([parameters[key] isKindOfClass:[NSNull class]]){
//                                                                       [formData appendPartWithFormData:[NSData data]
//                                                                                                   name:key];
//                                                                   }else if([parameters[key] isKindOfClass:[NSURL class]]){
//                                                                       NSURL *url = parameters[key];
//                                                                       if([url isFileURL] && [[NSFileManager defaultManager] isExecutableFileAtPath:[url path]]){
//                                                                           [formData appendPartWithFileURL:url
//                                                                                                      name:key
//                                                                                                  fileName:[[url path] lastPathComponent]
//                                                                                                  mimeType:[[self class] mimeTypeForFileAtPath:[url path]]
//                                                                                                     error:error];
//                                                                       }else{
//                                                                           [formData appendPartWithFormData:[[url absoluteString]dataUsingEncoding:NSUTF8StringEncoding]
//                                                                                                       name:key];
//                                                                       }
//                                                                   }else if([parameters[key] isKindOfClass:[NSArray class]] ||
//                                                                            [parameters[key] isKindOfClass:[NSDictionary class]] ||
//                                                                            [parameters[key] isKindOfClass:[NSSet class]]){
//                                                                       [formData appendPartWithFormData:[[parameters[key] jsonString] dataUsingEncoding:NSUTF8StringEncoding]
//                                                                                                   name:key];
//                                                                   }
//                                                                   
//                                                               }
//                                                           }else if ([parameters isKindOfClass:[NSData class]]){
//                                                               
//                                                           }
//                                                           
//                                                       }
//                                                                           error:error];
//}


//-(NSMutableURLRequest *)generateRawDataRequest:(NSString *)httpMethod
//                                      fullPath:(NSString *)fullPath
//                                    parameters:(NSDictionary *)parameters
//                                         error:(NSError **)error{
//    if(!MXWebClientInstance.requestSerializer.HTTPRequestHeaders[@"Content-Type"]){
//        [MXWebClientInstance.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    }
//    NSMutableURLRequest *mutableRequest = [MXWebClientInstance.requestSerializer requestWithMethod:httpMethod
//                                                                                         URLString:fullPath
//                                                                                        parameters:nil
//                                                                                             error:error];
//    id value = parameters;
//    if(parameters[@"rawData"]){
//        value = parameters[@"rawData"];
//    }
//    if ([value respondsToSelector:@selector(jsonString)]) {
//        mutableRequest.HTTPBody = [[value jsonString] dataUsingEncoding:NSUTF8StringEncoding];
//    }
//    else if([value isKindOfClass:[NSData class]]){
//        mutableRequest.HTTPBody = value;
//    }
//    else if([value isKindOfClass:[NSURL class]] && [((NSURL *)value) isFileURL]){
//        mutableRequest.HTTPBody = [NSData dataWithContentsOfURL:value];
//    }else{
//        NSAssert(false,@"unsupport parameter for raw form data!");
//        return nil;
//    }
//    
//    
//    return mutableRequest;
//}


-(NSMutableURLRequest *)generateDownloadRequest{
    NSMutableURLRequest* request = nil;//[[NSMutableURLRequest alloc] initWithURL:nil];
    //    request.HTTPMethod = httpMethod;
    return request;
}


#pragma mark - help functions
+ (NSString *) mimeTypeForFileAtPath: (NSString *) path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }
    return (__bridge_transfer NSString *)mimeType;
}

@end
