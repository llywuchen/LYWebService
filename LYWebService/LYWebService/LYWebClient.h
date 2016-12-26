//
//  LYWebClient.h
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "LYDataConverterFactory.h"
#import "LYPublicParamsFactory.h"

#define LYWebClientInstance [LYWebClient shareInstance]

typedef  NS_ENUM(NSInteger,LYPublicParamsType){
    LYPublicParamsInHeader = 0,//deafult
    LYPublicParamsInPath,
    LYPublicParamsInBody
};

@interface LYWebClient : AFHTTPSessionManager

/**
 * The base URL for the web service.
 */
@property(nonatomic,strong,nullable) NSURL* endPoint;

/**
 * The bundle where LYEngine' automatically generated files are located.
 * Defaults to the main bundle. Normally you do not need to set this property,
 * but it may be necessary when the bundle you are running is not the normal
 * app bundle, such as when running unit tests.
 */
@property(nonatomic,strong,nonnull) NSBundle* bundle;


/**
 * A factory that creates converters, which are used to convert request parameters
 * and response data. By default uses DRJsonConverterFactory.
 */
@property(nonatomic,strong,readonly,nullable) id<LYDataConverterFactoryDelegate> converterFactory;

@property(nonatomic,strong,readonly,nullable) id<LYPublicParamsFactoryDelegate> publicParamsFactory;


+ (LYWebClient* __nonnull)shareInstance;

- (void)setDataConverter:(id<LYDataConverter> _Nullable) dataConverter;

- (void)setPublicParams:(id<LYPublicParamsDelegate> _Nullable)publicParams;



- (id __nonnull)create:(Protocol* __nonnull)protocol;

- (id __nonnull)create:(Protocol* __nonnull)protocol host:(NSString *__nonnull)host;

- (id __nonnull)create:(Protocol* __nonnull)protocol publicParamsType:(LYPublicParamsType)publicParamsType publicParamsDic:(NSDictionary *_Nullable)publicParamsDic;

@end
