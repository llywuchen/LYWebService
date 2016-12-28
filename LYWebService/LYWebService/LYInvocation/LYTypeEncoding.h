//
//  LYTypeEncoding.h
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LYObjectTypeEncodingClass,
    LYIntegerNumberTypeEncodingClass,
    LYFloatingNumberTypeEncodingClass,
    LYOtherTypeEncodingClass
} LYTypeEncodingClass;


@interface LYTypeEncoding : NSObject

- (instancetype)initWithTypeEncoding:(const char*)encoding;

- (LYTypeEncodingClass)encodingClass;

- (NSString*)formatSpecifier;

@end
