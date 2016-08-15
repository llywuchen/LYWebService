//
//  MXTypeEncoding.h
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MXObjectTypeEncodingClass,
    MXIntegerNumberTypeEncodingClass,
    MXFloatingNumberTypeEncodingClass,
    MXOtherTypeEncodingClass
} MXTypeEncodingClass;


@interface MXTypeEncoding : NSObject

- (instancetype)initWithTypeEncoding:(const char*)encoding;

- (MXTypeEncodingClass)encodingClass;

- (NSString*)formatSpecifier;

@end
