//
//  Module1Api.h
//  MXEngineDemo
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXTextModel.h"

@protocol Module1Api <MXWebService>

@POST("/v2/user/login")
- (NSURLSessionDataTask*)login:(NSString*)loginName
                      passWord:(NSString*)password
                  suceessBlock:MX_SUCCESS_BLOCK(NSString*)callback
failBlock:MX_FAIL_BLOCK(NSString*)errorMessage;


@GET("/app/algorithm/home")
- (NSURLSessionDataTask*)getInfoWithSuceessBlock:MX_SUCCESS_BLOCK(NSArray<MXTextModel *> *)callback
failBlock:MX_FAIL_BLOCK(NSString*)errorMessage;

@GET("/v2/combo/groupHomepage")
- (NSURLSessionDataTask*)getGroupHomePageInfoWithSuceessBlock:MX_SUCCESS_BLOCK(NSArray<MXTextModel *> *)callback
failBlock:MX_FAIL_BLOCK(NSString*)errorMessage;



@end
