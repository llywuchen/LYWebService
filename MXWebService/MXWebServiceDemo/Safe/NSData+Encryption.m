//
//  NSData+Encryption.m
//  EaseMob
//
//  Created by Ji Fang on 3/8/13.
//  Copyright (c) 2013 Ji Fang. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "NSData+Encryption.h"

@implementation NSData (Encryption)

#pragma mark - Base64 Extension

+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    const char lookup[] =
    {
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
        99,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
        99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99
    };
    
    NSData *inputData = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = (const unsigned char *)[inputData bytes];
    
    long long maxOutputLength = (inputLength / 4 + 1) * 3;
    NSMutableData *outputData = [NSMutableData dataWithLength:(NSUInteger)maxOutputLength];
    unsigned char *outputBytes = (unsigned char *)[outputData mutableBytes];
    
    int accumulator = 0;
    long long outputLength = 0;
    unsigned char accumulated[] = {0, 0, 0, 0};
    for (long long i = 0; i < inputLength; i++)
    {
        unsigned char decoded = lookup[inputBytes[i] & 0x7F];
        if (decoded != 99)
        {
            accumulated[accumulator] = decoded;
            if (accumulator == 3)
            {
                outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);
                outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);
                outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];
            }
            accumulator = (accumulator + 1) % 4;
        }
    }
    
    //handle left-over data
    if (accumulator > 0) outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4);
    if (accumulator > 1) outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2);
    if (accumulator > 2) outputLength++;
    
    //truncate data to match actual output length
    outputData.length = (size_t)outputLength;
    return outputLength? outputData: nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    //ensure wrapWidth is a multiple of 4
    wrapWidth = (wrapWidth / 4) * 4;
    
    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    long long inputLength = [self length];
    const unsigned char *inputBytes = (const unsigned char *)[self bytes];
    
    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    maxOutputLength += wrapWidth? (maxOutputLength / wrapWidth) * 2: 0;
    unsigned char *outputBytes = (unsigned char *)malloc((size_t)maxOutputLength);
    
    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];
        
        //add line break
        if (wrapWidth && (outputLength + 2) % (wrapWidth + 2) == 0)
        {
            outputBytes[outputLength++] = '\r';
            outputBytes[outputLength++] = '\n';
        }
    }
    
    //handle left-over data
    if (i == inputLength - 2)
    {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] =   '=';
    }
    else if (i == inputLength - 1)
    {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }
    
    if (outputLength >= 4)
    {
        //truncate data to match actual output length
        outputBytes = (unsigned char *)realloc(outputBytes, (size_t)outputLength);
        return [[NSString alloc] initWithBytesNoCopy:outputBytes
                                               length:(size_t)outputLength
                                             encoding:NSASCIIStringEncoding
                                         freeWhenDone:YES];
    }
    else if (outputBytes)
    {
        free(outputBytes);
    }
    return @"";
}

- (NSString *)base64EncodedString
{
    return [self base64EncodedStringWithWrapWidth:0];
}


#pragma mark - AES Extension

#if 0
- (NSData *)AES256EncryptWithKey:(NSString *)key
{
    NSData *encrypted = nil;
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // input buffer, zero padding
    size_t dataLength = [self length];
    size_t bufferSize = (dataLength + kCCBlockSizeAES128 - 1) / 16 * 16;
    void *inputbuffer = malloc(bufferSize+1);
    void *outputBuffer = malloc(bufferSize+1);
    size_t numBytesEncrypted = 0;
    
    bzero(inputbuffer, bufferSize+1);
    bzero(outputBuffer, bufferSize+1);
    memcpy(inputbuffer, [self bytes], dataLength);
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          0,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          inputbuffer, bufferSize,
                                          outputBuffer, bufferSize,
                                          &numBytesEncrypted);
    
    
    if (cryptStatus == kCCSuccess) {
        encrypted = [NSData dataWithBytes:outputBuffer length:numBytesEncrypted];
    }
    free(inputbuffer);
    free(outputBuffer);
    
    return encrypted;
}
#endif

- (NSData *)AES256Decrypt {
    static Byte keyByte[] = {
        0x4a, 0x6f, 0x68, 0x6e, 0x73, 0x6f, 0x6e, 0x4d,
        0x61, 0x4a, 0x69, 0x46, 0x61, 0x6e, 0x67, 0x4a,
        0x65, 0x72, 0x76, 0x69, 0x73, 0x4c, 0x69, 0x75,
        0x4c, 0x69, 0x75, 0x53, 0x68, 0x61, 0x6f, 0x5a
    };
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:32];
    return [self AES256DecryptWithKey:keyData];
}

- (NSData *)AES256Encrypt {
    static Byte keyByte[] = {
        0x4a, 0x6f, 0x68, 0x6e, 0x73, 0x6f, 0x6e, 0x4d,
        0x61, 0x4a, 0x69, 0x46, 0x61, 0x6e, 0x67, 0x4a,
        0x65, 0x72, 0x76, 0x69, 0x73, 0x4c, 0x69, 0x75,
        0x4c, 0x69, 0x75, 0x53, 0x68, 0x61, 0x6f, 0x5a
    };
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:32];
    return [self AES256EncryptWithKey:keyData];
}

- (NSData *)AES256EncryptWithKey:(NSData *)key {
    
    static Byte keyByte[] = {
        0x36, 0x6f, 0x38, 0x64, 0x65, 0x35, 0x77, 0x33,
        0x75, 0x38, 0x6d, 0x36, 0x66, 0x34, 0x61, 0x6c,
        0x71, 0x6d, 0x78, 0x78, 0x6a, 0x77, 0x73, 0x73,
        0x73, 0x6d, 0x73, 0x73, 0x73, 0x6b, 0x77, 0x6d
    };
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:32];
    
    //AES256加密，密钥应该是32位的
    const void * keyPtr2 = [keyData bytes];
//    const void * keyPtr2 = [key bytes];
    //char (*keyPtr)[32] = keyPtr2;
    
    //对于块加密算法，输出大小总是等于或小于输入大小加上一个块的大小
    //所以在下边需要再加上一个块的大小
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr2, kCCKeySizeAES256,
                                          NULL,/* 初始化向量(可选) */
                                          [self bytes], dataLength,/*输入*/
                                          buffer, bufferSize,/* 输出 */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);//释放buffer
    return nil;
}

#if 0
- (NSData *)AES256DecryptWithKey:(NSString *)key
{
    NSData *decrypted = nil;
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          0,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        decrypted = [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    free(buffer);
    
    return decrypted;
}
#endif

- (NSData *)AES256DecryptWithKey:(NSData *)key {
    //同理，解密中，密钥也是32位的
    const void * keyPtr2 = [key bytes];
    char (*keyPtr)[32] = (char (*)[32])keyPtr2;
    
    //对于块加密算法，输出大小总是等于或小于输入大小加上一个块的大小
    //所以在下边需要再加上一个块的大小
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,/* 初始化向量(可选) */
                                          [self bytes], dataLength,/* 输入 */
                                          buffer, bufferSize,/* 输出 */
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}


#pragma mark -  AES 128
- (NSData *)AES128Encrypt {
    // app_testapp_testapp_testapp_test
    static Byte keyByte[] = {
        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
//        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
//        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74
    };
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:16];
    
    //AES256加密，密钥应该是32位的
    const void * keyPtr2 = [keyData bytes];
    //    const void * keyPtr2 = [key bytes];
    //char (*keyPtr)[32] = keyPtr2;
    
    //对于块加密算法，输出大小总是等于或小于输入大小加上一个块的大小
    //所以在下边需要再加上一个块的大小
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr2, kCCKeySizeAES128,
                                          NULL,/* 初始化向量(可选) */
                                          [self bytes], dataLength,/*输入*/
                                          buffer, bufferSize,/* 输出 */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);//释放buffer
    return nil;
}

- (NSData *)AES128Decrypt {
    // app_testapp_testapp_testapp_test
    static Byte keyByte[] = {
        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
//        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
//        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74
    };
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:16];
    
    //AES256加密，密钥应该是32位的
    const void * keyPtr2 = [keyData bytes];
//    //同理，解密中，密钥也是32位的
//    const void * keyPtr2 = [key bytes];
    char (*keyPtr)[16] = (char (*)[16])keyPtr2;
    
    //对于块加密算法，输出大小总是等于或小于输入大小加上一个块的大小
    //所以在下边需要再加上一个块的大小
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL,/* 初始化向量(可选) */
                                          [self bytes], dataLength,/* 输入 */
                                          buffer, bufferSize,/* 输出 */
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}


#pragma mark - MD5 Extenstion
+(NSData *)MD5Digest:(NSData *)input
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(input.bytes, (int)input.length, result);
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

+(NSString *)MD5HexDigest:(NSData *)input
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(input.bytes, (int)input.length, result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return ret;
}

-(NSData *)MD5Digest
{
    return [NSData MD5Digest:self];
}

-(NSString *)MD5HexDigest
{
    return [NSData MD5HexDigest:self];
}

@end
