//
//  LYTypeEncoding.h
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,LYTypeEncodingClass){
    LYObjectTypeEncodingClass,
    LYIntegerNumberTypeEncodingClass,
    LYFloatingNumberTypeEncodingClass,
    LYOtherTypeEncodingClass
};


@interface LYTypeEncoding : NSObject

- (instancetype)initWithTypeEncoding:(const char *)encoding;

- (LYTypeEncodingClass)encodingClass;

- (NSString *)formatSpecifier;

@end
