//
//  MXWebClient.m
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "MXWebClient.h"
#import "MXDataConverterFactory.h"
#import <objc/runtime.h>
#import "MXProtocolImpl.h"
#import "MXMethodDescription.h"

@implementation MXWebClient

- (instancetype)init{
    self = [super init];
    if(self){
        [self buildDefault];
    }
    return self;
}

+ (MXWebClient *)shareInstance{
    static MXWebClient *shareInstance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareInstance = [[MXWebClient alloc]init];
    });
    return shareInstance;
}

- (void)buildDefault{
    // defaults
    self.bundle = [NSBundle mainBundle];
    self.urlSession = [NSURLSession sharedSession];
    self.converterFactory = [[MXDataConverterFactory alloc] init];
}

- (Class)classImplForProtocol:(Protocol*)protocol
{
    NSString* protocolName = NSStringFromProtocol(protocol);
    NSString* className = [protocolName stringByAppendingString:@"_DRInternalImpl"];
    Class cls = nil;
    
    // make sure we only create the class once
    @synchronized(self.class) {
        cls = NSClassFromString(className);
        
        if (cls == nil) {
            cls = objc_allocateClassPair([MXProtocolImpl class], [className UTF8String], 0);
            class_addProtocol(cls, protocol);
            objc_registerClassPair(cls);
        }
    }
    
    return cls;
}

- (NSDictionary*)methodDescriptionsForProtocol:(Protocol*)protocol {
    NSURL* url = [self.bundle URLForResource:NSStringFromProtocol(protocol) withExtension:@"drproto"];
    NSAssert(url != nil, @"couldn't find proto file");
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:0 error:nil];
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    for (NSString* key in jsonDict) {
        result[key] = [[MXMethodDescription alloc] initWithDictionary:jsonDict[key]];
    }
    
    return result.copy;
}

- (id)create:(Protocol*)protocol
{
    Class cls = [self classImplForProtocol:protocol];
    MXProtocolImpl* obj = [[cls alloc] init];
    obj.protocol = protocol;
    obj.endPoint = self.endPoint;
    obj.urlSession = self.urlSession;
    obj.methodDescriptions = [self methodDescriptionsForProtocol:protocol];
    obj.converterFactory = self.converterFactory;
    return obj;
}

- (id __nonnull)create:(Protocol* __nonnull)protocol host:(NSString *__nonnull)host{
    Class cls = [self classImplForProtocol:protocol];
    MXProtocolImpl* obj = [[cls alloc] init];
    obj.protocol = protocol;
    obj.endPoint = [NSURL URLWithString:host];
    obj.urlSession = self.urlSession;
    obj.methodDescriptions = [self methodDescriptionsForProtocol:protocol];
    obj.converterFactory = self.converterFactory;
    return obj;
}

@end
