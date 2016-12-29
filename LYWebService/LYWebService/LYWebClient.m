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

/**
 *  是否开启https SSL 验证
 *
 *  @return YES为开启，NO为关闭
 */
#define openHttpsSSL YES
/**
 *  SSL 证书名称，仅支持cer格式。
 */
#define certificate @"certificate"

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
    
    [self setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone]];
    
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [JSONResponseSerializer serializer];
    
#if DEBUG
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
    self.customFactory = [[LYCustomFactory alloc] init];
}

#pragma mark --- getter and setter
- (void)setEndPoint:(NSURL *)endPoint{
    _endPoint = endPoint;
}

- (void)setDataConverter:(id<LYDataConverter>) dataConverter{
    [self.customFactory setDataConverter:dataConverter];
}

- (void)setPublicParams:(id<LYPublicParams>)publicParams{
    [self.customFactory setPubicParams:publicParams];
}

- (void)setSslCertificateName:(NSString *)sslCertificateName{
#if openHttpsSSL
    [self setSecurityPolicy:[self customSecurityPolicy:sslCertificateName]];
#endif
}


- (Class)classImplForProtocol:(Protocol *)protocol
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

- (NSDictionary *)methodDescriptionsForProtocol:(Protocol *)protocol {
    NSURL *url = [self.bundle URLForResource:NSStringFromProtocol(protocol) withExtension:@"lyproto"];
    NSAssert(url != nil, @"couldn't find proto file");
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:0 error:nil];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in jsonDict) {
        result[key] = [[LYMethodDescription alloc] initWithDictionary:jsonDict[key]];
    }
    
    return result.copy;
}

- (id)create:(Protocol *)protocol
{
    Class cls = [self classImplForProtocol:protocol];
    LYProtocolImpl *obj = [[cls alloc] init];
    obj.protocol = protocol;
    obj.endPoint = self.endPoint;
    obj.methodDescriptions = [self methodDescriptionsForProtocol:protocol];
    obj.dataConverter = [self.customFactory newDataConverter];
    return obj;
}

- (id)create:(Protocol *)protocol host:(NSString *)host{
    LYProtocolImpl *obj = [self create:protocol];
    obj.endPoint = [NSURL URLWithString:host];
    return obj;
}

- (id)create:(Protocol *)protocol publicParamsType:(LYPublicParamsType)publicParamsType publicParamsDic:(NSDictionary *)publicParamsDic{
    LYProtocolImpl *obj = [self create:protocol];
    obj.publicParamsType = publicParamsType;
    obj.publicParamsDic = publicParamsDic;
    return obj;
}

#pragma mark - private
- (AFSecurityPolicy*)customSecurityPolicy:(NSString *)sslCertificateName
{
    // /先导入证书
    NSString *cerPath = [self.bundle pathForResource:sslCertificateName ofType:@"cer"];//证书的路径
    NSAssert(cerPath!=nil, @"ssl certificate file path not excists!");
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = YES;
    if (certData) {
        securityPolicy.pinnedCertificates = [NSSet setWithObject:certData];
    }
    return securityPolicy;
}

@end
