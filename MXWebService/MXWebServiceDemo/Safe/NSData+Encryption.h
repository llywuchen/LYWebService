//
//  NSData+Encryption.h
//  EaseMob
//
//  Created by Ji Fang on 3/8/13.
//  Copyright (c) 2013 Ji Fang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Encryption)

// Base64 encoding/decoding extension
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;

// AES encrypt/decrypt extension
- (NSData *)AES256Encrypt;
- (NSData *)AES256Decrypt;
- (NSData *)AES256EncryptWithKey:(NSData *)key;
- (NSData *)AES256DecryptWithKey:(NSData *)key;

- (NSData *)AES128Encrypt;
- (NSData *)AES128Decrypt;

// MD5 extension
+(NSData *)MD5Digest:(NSData *)input;
+(NSString *)MD5HexDigest:(NSData *)input;
-(NSData *)MD5Digest;
-(NSString *)MD5HexDigest;

@end
