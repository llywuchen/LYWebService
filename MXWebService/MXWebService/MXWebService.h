//
//  MXWebService.h
//  MXWebService
//
//  Created by lly on 16/8/15.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for MXWebService.
FOUNDATION_EXPORT double MXWebServiceVersionNumber;

//! Project version string for MXWebService.
FOUNDATION_EXPORT const unsigned char MXWebServiceVersionString[];

#import "MXGomePlusConverter.h"
#import "MXDataConverterFactory.h"
#import "MXDictionryConvertable.h"
#import "MXWebClient.h"


#define MXWebRequest(aprotocol) ((NSObject<aprotocol> *)[MXWebClientInstance create:@protocol(aprotocol)])

#ifdef MX_SWIFT_COMPAT
#define MX_SUCCESS_BLOCK(type) (void (^ __nonnull)(type __nullable result, NSURLResponse* __nullable response))
#define MX_FAIL_BLOCK(type) (void (^ __nonnull)(type __nullable errorMessage, NSURLResponse* __nullable response, NSError* __nullable error))
#else
#define MX_SUCCESS_BLOCK(type) (void (^)(type result, NSURLResponse *response))
#define MX_FAIL_BLOCK(type) (void (^)(type errorMessage, NSURLResponse *response, NSError* error))
#endif

#define GET(unused)		required
#define POST(unused)	required
#define DELETE(unused)	required
#define PUT(unused)		required
#define HEAD(unused)	required
#define PATCH(unused)	required

#define Body(unused)	required
#define Headers(...)	required
#define FormUrlEncoded	required

@protocol MXDataConverterFactoryDelegate;


@protocol MXWebService <NSObject>

- (NSURL*)endPoint;
- (NSURLSession*)urlSession;
- (NSDictionary*)methodDescriptions;
- (id<MXDataConverterFactoryDelegate>)converterFactory;

@end


