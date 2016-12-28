//
//  LYWebClient.m
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "LYWebClient.h"
#import <objc/runtime.h>
#import "LYProtocolImpl.h"
#import "LYMethodDescription.h"

@interface JSONResponseSerializer : AFJSONResponseSerializer

@end

@implementation JSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)errorPointer
{
    id responseObject = [super responseObjectForResponse:response data:data error:errorPointer];
    if (*errorPointer) {
        NSError *error = *errorPointer;
        NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
        userInfo[@"responseObject"] = responseObject;
        *errorPointer = [NSError errorWithDomain:error.domain code:error.code userInfo:[userInfo copy]];
    }
    return responseObject;
}

@end


@interface LYWebClient ()

@property(nonatomic,strong,readwrite) id<LYDataConverterFactoryDelegate,LYPublicParamsFactoryDelegate> customFactory;

@end

@implementation LYWebClient

- (instancetype)init{
    self = [super init];
    if(self){
        [self buildDefault];
    }
    return self;
}

+ (LYWebClient *)shareInstance{
    static LYWebClient *shareInstance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareInstance = [[LYWebClient alloc]init];
    });
    return shareInstance;
}

- (void)buildDefault{
    
#if DEBUG
    //https 证书验证
    NSString * cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cer"];
    if(cerPath){
        NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
        NSLog(@"%@", cerData);
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[[NSSet alloc] initWithObjects:cerData, nil]];
    }
    self.securityPolicy.allowInvalidCertificates = NO;
    [self.securityPolicy setValidatesDomainName:YES];
    
#endif
    
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [JSONResponseSerializer serializer];
#ifdef DEBUG
    self.requestSerializer.timeoutInterval = 5.0f;
#else
    self.requestSerializer.timeoutInterval = 20.0f;
#endif
    //    [self.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"accept"];
    
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    
    // defaults
    self.bundle = [NSBundle mainBundle];
    //    self.urlSession = [NSURLSession sharedSession];
    self.customFactory = [[LYCustomFactory alloc] init];
}

#pragma mark --- getter and setter
- (void)setEndPoint:(NSURL *)endPoint{
    _endPoint = endPoint;
}

- (void)setDataConverter:(id<LYDataConverter>) dataConverter{
    [self.customFactory setDataConverter:dataConverter];
}

- (void)setPublicParams:(id<LYPublicParams> _Nullable)publicParams{
    [self.customFactory setPubicParams:publicParams];
    //    NSDictionary *pubicParamsDic = [[self.publicParamsFactory pubicParamsDelegate] pubicParams];
    //    for(NSString *key in pubicParamsDic.allKeys){
    //        [self.requestSerializer setValue:[pubicParamsDic objectForKey:key] forHTTPHeaderField:key];
    //    }
}


- (Class)classImplForProtocol:(Protocol*)protocol
{
    NSString* protocolName = NSStringFromProtocol(protocol);
    NSString* className = [protocolName stringByAppendingString:@"_LYInternalImpl"];
    Class cls = nil;
    
    // make sure we only create the class once
    @synchronized(self.class) {
        cls = NSClassFromString(className);
        
        if (cls == nil) {
            cls = objc_allocateClassPair([LYProtocolImpl class], [className UTF8String], 0);
            class_addProtocol(cls, protocol);
            objc_registerClassPair(cls);
        }
    }
    
    return cls;
}

- (NSDictionary*)methodDescriptionsForProtocol:(Protocol*)protocol {
    NSURL* url = [self.bundle URLForResource:NSStringFromProtocol(protocol) withExtension:@"lyproto"];
    NSAssert(url != nil, @"couldn't find proto file");
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:0 error:nil];
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    for (NSString* key in jsonDict) {
        result[key] = [[LYMethodDescription alloc] initWithDictionary:jsonDict[key]];
    }
    
    return result.copy;
}

- (id)create:(Protocol*)protocol
{
    Class cls = [self classImplForProtocol:protocol];
    LYProtocolImpl* obj = [[cls alloc] init];
    obj.protocol = protocol;
    obj.endPoint = self.endPoint;
    //    obj.urlSession = self.urlSession;
    obj.methodDescriptions = [self methodDescriptionsForProtocol:protocol];
    obj.dataConverter = [self.customFactory newDataConverter];
    return obj;
}

- (id __nonnull)create:(Protocol* __nonnull)protocol host:(NSString *__nonnull)host{
    Class cls = [self classImplForProtocol:protocol];
    LYProtocolImpl* obj = [[cls alloc] init];
    obj.protocol = protocol;
    obj.endPoint = [NSURL URLWithString:host];
    //    obj.urlSession = self.urlSession;
    obj.methodDescriptions = [self methodDescriptionsForProtocol:protocol];
    obj.dataConverter = [self.customFactory newDataConverter];
    return obj;
}

- (id __nonnull)create:(Protocol* __nonnull)protocol publicParamsType:(LYPublicParamsType)publicParamsType publicParamsDic:(NSDictionary *)publicParamsDic{
    Class cls = [self classImplForProtocol:protocol];
    LYProtocolImpl* obj = [[cls alloc] init];
    obj.protocol = protocol;
    obj.endPoint = self.endPoint;
    obj.publicParamsType = publicParamsType;
    obj.publicParamsDic = publicParamsDic;
    obj.methodDescriptions = [self methodDescriptionsForProtocol:protocol];
    obj.dataConverter = [self.customFactory newDataConverter];
    return obj;
}
@end
