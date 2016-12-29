//
//  LYTextApi.h
//  LYEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#ifndef LYTextApi_h
#define LYTextApi_h
@class LYTextModel;

@protocol LYTextApi <LYWebService>

@POST("/login")
- (NSURLSessionDataTask*)login:(NSString*)userName
                      passWord:(NSString*)passWord
                  suceessBlock:LY_SUCCESS_BLOCK(NSString*)callback
failBlock:LY_FAIL_BLOCK(NSString*)errorMessage;

@GET("/967-1")
- (NSURLSessionDataTask*)getInfo:(NSString *)showapi_appid
                    suceessBlock:LY_SUCCESS_BLOCK(NSArray<LYTextModel *> *)callback
failBlock:LY_FAIL_BLOCK(NSString*)errorMessage;

@end


#endif /* LYTextApi_h */
