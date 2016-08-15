//
//  MXTextApi.h
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#ifndef MXTextApi_h
#define MXTextApi_h
@class MXTextModel;

@protocol MXTextApi <MXWebService>

@POST("/login")
- (NSURLSessionDataTask*)login:(NSString*)userName
                      passWord:(NSString*)passWord
                  suceessBlock:MX_SUCCESS_BLOCK(NSString*)callback
                failBlock:MX_FAIL_BLOCK(NSString*)errorMessage;
@GET("/getinfo")
- (NSURLSessionDataTask*)getInfo:(NSInteger)userId
                    suceessBlock:MX_SUCCESS_BLOCK(NSString*)callback
                failBlock:MX_FAIL_BLOCK(NSString*)errorMessage;

@end


#endif /* MXTextApi_h */
