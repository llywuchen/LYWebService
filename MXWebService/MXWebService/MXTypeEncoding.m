//
//  MXTypeEncoding.m
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "MXTypeEncoding.h"

@interface MXTypeEncoding ()

@property(nonatomic,strong,readonly) NSString* encoding;

@end

@implementation MXTypeEncoding

+ (NSArray*)integerEncodings
{
    static NSArray* encodings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encodings = @[ @"c",
                       @"i",
                       @"s",
                       @"l",
                       @"q",
                       @"C",
                       @"I",
                       @"S",
                       @"L",
                       @"Q" ];
    });
    
    return encodings;
}

+ (NSDictionary*)formatSpecifiers
{
    static NSDictionary* specifiers = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        specifiers = @{
                       @"c" : @"%c",
                       @"i" : @"%d",
                       @"s" : @"%hd",
                       @"l" : @"%ld",
                       @"q" : @"%lld",
                       @"C" : @"%c",
                       @"I" : @"%u",
                       @"S" : @"%hu",
                       @"L" : @"%lu",
                       @"Q" : @"%llu",
                       @"f" : @"%f",
                       @"d" : @"%f",
                       @"@" : @"%@",
                       };
    });
    
    return specifiers;
}

- (instancetype)initWithTypeEncoding:(const char*)encoding
{
    self = [super init];
    
    if (self) {
        _encoding = [[NSString alloc] initWithCString:encoding encoding:NSASCIIStringEncoding];
    }
    
    return self;
}

- (MXTypeEncodingClass)encodingClass
{
    if ([self.encoding isEqualToString:@"@"]) {
        return MXObjectTypeEncodingClass;
    } else if ([self.encoding isEqualToString:@"f"] || [self.encoding isEqualToString:@"d"]) {
        return MXFloatingNumberTypeEncodingClass;
    } else if ([[self.class integerEncodings] containsObject:self.encoding]) {
        return MXIntegerNumberTypeEncodingClass;
    } else {
        return MXOtherTypeEncodingClass;
    }
}

- (NSString*)formatSpecifier
{
    return [self.class formatSpecifiers][self.encoding];
}


@end
