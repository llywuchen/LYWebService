//
//  NSInvocation+LYUtils.m
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "NSInvocation+LYUtils.h"

@implementation NSInvocation (LYUtils)

- (LYTypeEncoding *)typeEncodingForParameterAtIndex:(NSUInteger)index
{
    // must increment past the first 2 implicit parameters
    index += 2;
    
    const char* type = [self.methodSignature getArgumentTypeAtIndex:index];
    return [[LYTypeEncoding alloc] initWithTypeEncoding:type];
}

- (NSObject *)objectValueForParameterAtIndex:(NSUInteger)index
{
    // must increment past the first 2 implicit parameters
    index += 2;
    
    NSObject * __unsafe_unretained obj = nil;
    [self getArgument:&obj atIndex:index];
    
    return obj;
}

- (id)valueForParameterAtIndex:(NSUInteger)index
{
    LYTypeEncoding *encoding = [self typeEncodingForParameterAtIndex:index];
    
    // must increment past the first 2 implicit parameters
    index += 2;
    
    switch (encoding.encodingClass) {
        case LYObjectTypeEncodingClass: {
            NSObject *__unsafe_unretained obj = nil;
            [self getArgument:&obj atIndex:index];
            return [NSString stringWithFormat:@"%@", obj];
        }
            
        case LYIntegerNumberTypeEncodingClass: {
            long long value = 0;
            [self getArgument:&value atIndex:index];
            return @(value);//[NSString stringWithFormat:[encoding formatSpecifier], value];
        }
            
        case LYFloatingNumberTypeEncodingClass: {
            double value = 0;
            [self getArgument:&value atIndex:index];
            return @(value);//[NSString stringWithFormat:[encoding formatSpecifier], value];
        }
            
        case LYOtherTypeEncodingClass: {
            NSAssert(NO, @"Unrecognized parameter type");
            return nil;
        }
    }
}


@end
