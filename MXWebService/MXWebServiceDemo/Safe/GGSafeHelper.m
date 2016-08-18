//
//  GGSafeHelper.m
//  GMBuy
//
//  Created by cn on 15/8/5.
//  Copyright (c) 2015年 cn. All rights reserved.
//

#import "GGSafeHelper.h"
#import "NSString+Encryption.h"

@implementation GGSafeHelper

// AES + BASE64加密
+ (NSString *)aesAndBase64:(NSString *)sourceString
{
    if ([sourceString length] > 0)
    {
        // aes + base64
        NSString *aesStr = [sourceString AES128Base64Encrypt];
        return aesStr;
    }
    
    return nil;
}

@end
