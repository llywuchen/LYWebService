//
//  MXWebClient.h
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXDataConverterFactory.h"

#define MXWebClientInstance [MXWebClient shareInstance]

@interface MXWebClient : NSObject

/**
 * The base URL for the web service.
 */
@property(nonatomic,strong,nullable) NSURL* endPoint;

/**
 * The bundle where MXEngine' automatically generated files are located.
 * Defaults to the main bundle. Normally you do not need to set this property,
 * but it may be necessary when the bundle you are running is not the normal
 * app bundle, such as when running unit tests.
 */
@property(nonatomic,strong,nullable) NSBundle* bundle;

/**
 * The NSURLSession to be used by all instances of NSURLSessionTask generated
 * by the web service. Defaults to the shared session.
 */
@property(nonatomic,strong,nullable) NSURLSession* urlSession;

/**
 * A factory that creates converters, which are used to convert request parameters
 * and response data. By default uses DRJsonConverterFactory.
 */
@property(nonatomic,strong,nullable) id<MXDataConverterFactoryDelegate> converterFactory;

+ (MXWebClient* __nonnull)shareInstance;

- (id __nonnull)create:(Protocol* __nonnull)protocol;

- (id __nonnull)create:(Protocol* __nonnull)protocol host:(NSString *__nonnull)host;

@end
