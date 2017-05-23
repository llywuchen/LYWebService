//
//  LYWebService.h
//  LYWebService
//
//  Created by lly on 16/8/15.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for LYWebService.
FOUNDATION_EXPORT double LYWebServiceVersionNumber;

//! Project version string for LYWebService.
FOUNDATION_EXPORT const unsigned char LYWebServiceVersionString[];

#import "LYCustomFactory.h"
#import "LYWebClient.h"


#define LYWebRequest(aprotocol) ((NSObject<aprotocol> *)[LYWebClientInstance create:@protocol(aprotocol)])

#define LYWebRequestSpecial(aprotocol,pubicParamsType,pubicParamsDic) [LYWebClientInstance create:@protocol(aprotocol) publicParamsType:pubicParamsType publicParamsDic:pubicParamsDic]


#ifdef LY_SWIFT_COMPAT
#define LY_SUCCESS_BLOCK(type) (void (^ __nonnull)(type __nullable result, NSURLResponse* __nullable response))
#define LY_FAIL_BLOCK(type) (void (^ __nonnull)(type __nullable errorMessage, NSURLResponse* __nullable response, NSError* __nullable error))
#else
#define LY_SUCCESS_BLOCK(type) (void (^)(type result, NSURLResponse *response))
#define LY_FAIL_BLOCK(type) (void (^)(type errorMessage, NSURLResponse *response, NSError* error))
#endif

#define GET(unused)		required
#define POST(unused)	required
#define DELETE(unused)	required
#define PUT(unused)		required
#define HEAD(unused)	required
#define PATCH(unused)	required


#define Body(unused)	required
#define Headers(...)	required

//body type default is formData
#define FormData        required
#define FormUrlEncoded   required
#define FormRaw         required

//Cache time example: Cache(1D) Cache(1H)
#define Cache(unused)   required

@protocol LYDataConverterFactoryDelegate;


@protocol LYWebService <NSObject>

//- (NSURL*)endPoint;
//- (NSURLSession*)urlSession;
//- (NSDictionary*)methodDescriptions;
//- (id<LYDataConverter>)dataConverter;
//
//@optional
//@property (nonatomic,assign) LYPublicParamsType publicParamsType;

@end


