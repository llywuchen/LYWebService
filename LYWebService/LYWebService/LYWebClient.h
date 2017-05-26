//
//  LYWebClient.h
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "LYCustomFactory.h"

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
@property (nonatomic,strong) NSURL *endPoint;

/**
 * The bundle where LYEngine' automatically generated files are located.
 * Defaults to the main bundle. Normally you do not need to set this property,
 * but it may be necessary when the bundle you are running is not the normal
 * app bundle, such as when running unit tests.
 */
@property (nonatomic,strong) NSBundle *bundle;

@property (nonatomic,strong) NSString *sslCertificateName;


/**
 * A factory that creates converters, which are used to convert request parameters
 * and response data. By default uses LYCustomFactory.
 */
@property (nonatomic,strong,readonly) id<LYDataConverterFactoryDelegate,LYPublicParamsFactoryDelegate> customFactory;

+ (LYWebClient *)shareInstance;

- (void)setDataConverter:(id<LYDataConverter>) dataConverter;

- (void)setPublicParams:(id<LYPublicParams>)publicParams;



- (id)create:(Protocol *)protocol;

- (id)create:(Protocol *)protocol bundle:(NSBundle *)bundle host:(NSString *)host;

- (id)create:(Protocol *)protocol host:(NSString *)host;

- (id)create:(Protocol *)protocol publicParamsType:(LYPublicParamsType)publicParamsType publicParamsDic:(NSDictionary *)publicParamsDic;

@end
