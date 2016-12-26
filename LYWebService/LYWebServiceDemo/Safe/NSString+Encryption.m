//
//  NSString+Encryption.m
//  EaseMob
//
//  Created by Ji Fang on 3/8/13.
//  Copyright (c) 2013 Ji Fang. All rights reserved.
//

#import "NSString+Encryption.h"
#import "NSData+Encryption.h"

#define kKeyLength 32

@implementation NSString (Encryption)

+ (NSString *)stringWithBase64EncodedString:(NSString *)string
{
    NSData *data = [NSData dataWithBase64EncodedString:string];
    if (data) {
        return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSString *)base64EncodedString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedString];
}

- (NSString *)base64DecodedString
{
    return [NSString stringWithBase64EncodedString:self];
}

- (NSData *)base64DecodedData
{
    return [NSData dataWithBase64EncodedString:self];
}

#pragma mark - AES Extension

//- (NSString *)AES256EncryptWithKey:(NSData *)key
//{
//    NSData *value = [self dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *encryptedData = [value AES256EncryptWithKey:key];
//    if (encryptedData != nil) {
//        return [encryptedData base64EncodedString];
//    } else {
//        return @"";
//    }
//
//}

- (NSString *)AES256Base64EncryptWithKey:(NSData *)key
{
    NSData *value = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [value AES256EncryptWithKey:key];
    if (encryptedData != nil) {
        return [encryptedData base64EncodedString];
    } else {
        return @"";
    }
}

- (NSString *)AES256Base64DecryptWithKey:(NSData *)key
{
    NSData *encryptedData = [self base64DecodedData];
    if (encryptedData != nil) {
        NSData *value = [encryptedData AES256DecryptWithKey:key];
        if (value != nil && [value bytes] != NULL) {
            const char *bytes = (const char *)[value bytes];
            unsigned int length = [value length];
            int realLength;
            for (realLength = length; realLength >0; --realLength) {
                if (bytes[realLength-1] == 0)
                    continue;
                else 
                    break;
            }
            return [[NSString alloc] initWithBytes:bytes length:realLength encoding:NSUTF8StringEncoding];
        } else {
            return @"";
        }
    } else {
        return @"";
    }
}

- (NSString *)AES256Base64Encrypt
{
    static Byte keyByte[] = {
        0x4a, 0x6f, 0x68, 0x6e, 0x73, 0x6f, 0x6e, 0x4d,
        0x61, 0x4a, 0x69, 0x46, 0x61, 0x6e, 0x67, 0x4a,
        0x65, 0x72, 0x76, 0x69, 0x73, 0x4c, 0x69, 0x75,
        0x4c, 0x69, 0x75, 0x53, 0x68, 0x61, 0x6f, 0x5a
    };
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:32];

    return [self AES256Base64EncryptWithKey:keyData];
}

- (NSString *)AES256Base64Decrypt
{
    static Byte keyByte[] = {
        0x4a, 0x6f, 0x68, 0x6e, 0x73, 0x6f, 0x6e, 0x4d,
        0x61, 0x4a, 0x69, 0x46, 0x61, 0x6e, 0x67, 0x4a,
        0x65, 0x72, 0x76, 0x69, 0x73, 0x4c, 0x69, 0x75,
        0x4c, 0x69, 0x75, 0x53, 0x68, 0x61, 0x6f, 0x5a
    };
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:32];
    
    return [self AES256Base64DecryptWithKey:keyData];
}

#pragma mark aes128-base64
- (NSString *)AES128Base64Encrypt
{
    // "app_testapp_testapp_testapp_test"
    static Byte keyByte[] = {
        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
//        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
//        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74
    };
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:16];
    
    return [self AES128Base64EncryptWithKey:keyData];
}

- (NSString *)AES128Base64Decrypt
{
    static Byte keyByte[] = {
        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
//        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
//        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74,
        0x61, 0x70, 0x70, 0x5f, 0x74, 0x65, 0x73, 0x74
    };
    NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:16];
    
    return [self AES128Base64DecryptWithKey:keyData];
}

- (NSString *)AES128Base64EncryptWithKey:(NSData *)key
{
    NSData *value = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [value AES128Encrypt];
    if (encryptedData != nil) {
        return [encryptedData base64EncodedString];
    } else {
        return @"";
    }
}

- (NSString *)AES128Base64DecryptWithKey:(NSData *)key
{
    NSData *encryptedData = [self base64DecodedData];
    if (encryptedData != nil) {
        NSData *value = [encryptedData AES128Decrypt];
        if (value != nil && [value bytes] != NULL) {
            const char *bytes = (const char *)[value bytes];
            unsigned int length = [value length];
            int realLength;
            for (realLength = length; realLength >0; --realLength) {
                if (bytes[realLength-1] == 0)
                    continue;
                else
                    break;
            }
            return [[NSString alloc] initWithBytes:bytes length:realLength encoding:NSUTF8StringEncoding];
        } else {
            return @"";
        }
    } else {
        return @"";
    }
}


#pragma mark - MD5 Extension

+ (NSString *)MD5HexDigest:(NSString *)input
{
    NSData *data = [NSData dataWithBase64EncodedString:input];
    return [data MD5HexDigest];
}

- (NSString *)MD5HexDigest
{
    return [NSString MD5HexDigest:self];
}

#pragma mark RC4
+(NSString*) HloveyRC4:(NSString*)aInput key:(NSString*)aKey {
    NSMutableArray *iS = [[NSMutableArray alloc] initWithCapacity:256];
    NSMutableArray *iK = [[NSMutableArray alloc] initWithCapacity:256];
    
    for (int i= 0; i<256; i++) {
        [iS addObject:[NSNumber numberWithInt:i]];
    }
    
    int j=1;
    
    for (short i=0; i<256; i++) {
        
        UniChar c = [aKey characterAtIndex:i%aKey.length];
        
        [iK addObject:[NSNumber numberWithChar:c]];
    }
    
    j=0;
    
    for (int i=0; i<255; i++) {
        int is = [[iS objectAtIndex:i] intValue];
        UniChar ik = (UniChar)[[iK objectAtIndex:i] charValue];
        
        j = (j + is + ik)%256;
        NSNumber *temp = [iS objectAtIndex:i];
        [iS replaceObjectAtIndex:i withObject:[iS objectAtIndex:j]];
        [iS replaceObjectAtIndex:j withObject:temp];
        
    }
    
    int i=0;
    j=0;
    
    NSString *result = aInput;
    
    for (short x=0; x<[aInput length]; x++) {
        i = (i+1)%256;
        
        int is = [[iS objectAtIndex:i] intValue];
        j = (j+is)%256;
        
        int is_i = [[iS objectAtIndex:i] intValue];
        int is_j = [[iS objectAtIndex:j] intValue];
        
        int t = (is_i+is_j) % 256;
        int iY = [[iS objectAtIndex:t] intValue];
        
        UniChar ch = (UniChar)[aInput characterAtIndex:x];
        UniChar ch_y = ch^iY;
        
        result = [result stringByReplacingCharactersInRange:NSMakeRange(x, 1) withString:[NSString stringWithCharacters:&ch_y length:1]];
//        result = [result stringByReplacingCharactersInRange:NSMakeRange(x, 1) withString:[[NSString  alloc]initWithBytes:(UniChar*)&ch_y length:1 encoding:NSUTF8StringEncoding]];
//
//        - (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;
    }
    
//    [iS release];
//    [iK release];
    
    return result;
}

typedef unsigned long ULONG;

static void rc4_init(unsigned char *s, unsigned char *key, unsigned long Len) //初始化函数
{
    int i =0, j = 0;
    unsigned char k[256] = {0};
    UInt8 tmp = 0;
    for (i=0;i<256;i++) {
        s[i] = i;
        k[i] = key[i%Len];
    }
    for (i=0; i<256; i++) {
        j=(j+s[i]+k[i])%256;
        tmp = s[i];
        s[i] = s[j]; //交换s[i]和s[j]
        s[j] = tmp;
    }
}

static void rc4_crypt(unsigned char *s, unsigned char *Data, unsigned long Len) //加解密
{
    int i = 0, j = 0, t = 0;
    unsigned long k = 0;
    unsigned char tmp;
    for(k=0;k<Len;k++) {
        i=(i+1)%256;
        j=(j+s[i])%256;
        tmp = s[i];
        s[i] = s[j]; //交换s[x]和s[y]
        s[j] = tmp;
        t=(s[i]+s[j])%256;
        Data[k] ^= s[t];
    }
}

+(NSString*)HloveyRC4_32:(NSString*)aInput key:(NSString*)aKey{
//    char* k = RC4_KEY.UTF8String;
    unsigned char s[256] = {0};
    int len= strlen(aInput.UTF8String);
    
    unsigned char result[16];
    
//    char input[len+1];
//    memset(buffer,0,len+1);
    unsigned char * inputData = (unsigned char *)aInput.UTF8String;
    rc4_init(s,(unsigned char *)@"a".UTF8String,32);
    rc4_crypt(s,inputData,strlen((const char *)inputData));
    
    for(int i = 0;i<16;i++){
        result[0] = inputData[0];
    }
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
//    NSString *str = @"测试转换";
//    UInt8 buff_str[1024];
//    memcpy(buff_str,[str UTF8String], [str length]+1);
//    NSLog(@"char = %s",buff_str);
//    
////    NSString *str_From_buff = [NSString stringWithCString:(char*)aInput.UTF8String encoding:NSUTF8StringEncoding];
////    NSLog(@"string = %@",str_From_buff);
////    
////    NSString *marketPacket = [NSString stringWithCString:aInput encoding:NSUTF8StringEncoding];
//    return marketPacket;
}
//
//-(UInt8*)NSStringTOUInt8:(NSString*)str{
//    UInt8 buff_str[1024];
//    memcpy(buff_str,[str UTF8String], [str length]+1);
////    NSString *str_From_buff = [NSString stringWithCString:(char*)buff_str encoding:NSUTF8StringEncoding];
//    
//    UInt8* u = &buff_str;
//    strcpy (u,buff_str);
//    return u;
//}
//
//-(NSString*)NSStringTOUInt8:(UInt8*)char8_str{
//    UInt8 buff_str[1024];
//    memcpy(buff_str,[str UTF8String], [str length]+1);
//    NSString *str_From_buff = [NSString stringWithCString:(char*)buff_str encoding:NSUTF8StringEncoding];
//    return str_From_buff;
//}

+ (NSString *)hexStringFromData:(NSData *)myD{
    
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    NSLog(@"%@",hexStr);
    
    return hexStr;
}

+(NSString*)stringFromHexString:(NSString*)hexString{
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
//    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}

-(NSData*)dataFromHexString{
//    NSString*hexString = @"3e435fab9c34891f";//16进制字符串
    
    int j=0;
    
    Byte bytes[128];  ///3ds key的Byte 数组， 128位
    
    for(int i=0;i<[self length];i++)
        
    {
        
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [self characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        
        int int_ch1;
        
        if(hex_char1 >= '0' && hex_char1 <='9')
            
            int_ch1 = (hex_char1-48)*16;   //// 0的Ascll - 48
        
        else if(hex_char1 >= 'A' && hex_char1 <='F')
        
        int_ch1 = (hex_char1-55)*16; //// A的Ascll - 65
        
        else
            
            int_ch1 = (hex_char1-87)*16; //// a的Ascll - 97
        
        i++;
        
        unichar hex_char2 = [self characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        
        int int_ch2;
        
        if(hex_char2 >= '0' && hex_char2 <='9')
            
            int_ch2 = (hex_char2-48); //// 0的Ascll - 48
        
        else if(hex_char1 >= 'A' && hex_char1 <='F')
        
            int_ch2 = hex_char2-55; //// A的Ascll - 65
        
        else
            
            int_ch2 = hex_char2-87; //// a的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        
//        NSLog(@"int_ch=%d",int_ch);
        
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        
        j++;
        
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:128];
    
//    NSLog(@"newData=%@",newData);
    
    return newData;
}
@end
