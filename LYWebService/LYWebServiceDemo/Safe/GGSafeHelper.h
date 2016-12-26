//
//  GGSafeHelper.h
//  GMBuy
//
//  Created by cn on 15/8/5.
//  Copyright (c) 2015年 cn. All rights reserved.
//

/**
 *
 *  加密帮助类
 *
 */

#import <Foundation/Foundation.h>

//#define GGSafeHelperDefaultAESKey @"app_testapp_test"
//#define GGSafeHelperDefaultAESKey @"aass"

@interface GGSafeHelper : NSObject

// AES + BASE64加密
+ (NSString *)aesAndBase64:(NSString *)sourceString;

@end
