//
//  NSString+Encryption.h
//  EaseMob
//
//  Created by Ji Fang on 3/8/13.
//  Copyright (c) 2013 Ji Fang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encryption)

// Base64 encoding/decoding extension
+ (NSString *)stringWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSData *)base64DecodedData;

// AES encrypt/decrypt extension
- (NSString *)AES256Base64Encrypt;
- (NSString *)AES256Base64Decrypt;
- (NSString *)AES256Base64EncryptWithKey:(NSData *)key;
- (NSString *)AES256Base64DecryptWithKey:(NSData *)key;

- (NSString *)AES128Base64Encrypt;
- (NSString *)AES128Base64Decrypt;

// MD5 extenstion
+ (NSString *)MD5HexDigest:(NSString *)input;
- (NSString *)MD5HexDigest;

//RC4 extenstion
+(NSString*)HloveyRC4:(NSString*)aInput key:(NSString*)aKey;
+(NSString*)HloveyRC4_32:(NSString*)aInput key:(NSString*)aKey;

+ (NSString *)hexStringFromData:(NSData *)myD;
+(NSString*)stringFromHexString:(NSString*)hexString;
-(NSData*)dataFromHexString;
@end
