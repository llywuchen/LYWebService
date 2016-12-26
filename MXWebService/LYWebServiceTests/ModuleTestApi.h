//
//  Module1Api.h
//  LYEngineDemo
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYTextModel.h"

@protocol Module1Api <LYWebService>

@POST("/v2/user/login")
- (NSURLSessionDataTask*)login:(NSString*)loginName
                      passWord:(NSString*)password
                  suceessBlock:LY_SUCCESS_BLOCK(NSString*)callback
failBlock:LY_FAIL_BLOCK(NSString*)errorMessage;

@POST("/user/login.json")
- (NSURLSessionDataTask*)loginV1:(NSString*)loginName
                        passWord:(NSString*)password
                    suceessBlock:LY_SUCCESS_BLOCK(NSString*)callback
failBlock:LY_FAIL_BLOCK(NSString*)errorMessage;


@GET("/app/algorithm/home")
- (NSURLSessionDataTask*)getInfoWithSuceessBlock:LY_SUCCESS_BLOCK(NSArray<LYTextModel *> *)callback
failBlock:LY_FAIL_BLOCK(NSString*)errorMessage;

@GET("/v2/combo/groupHomepage")
- (NSURLSessionDataTask*)getGroupHomePageInfoWithSuceessBlock:LY_SUCCESS_BLOCK(NSArray<LYTextModel *> *)callback
failBlock:LY_FAIL_BLOCK(NSString*)errorMessage;



@end
