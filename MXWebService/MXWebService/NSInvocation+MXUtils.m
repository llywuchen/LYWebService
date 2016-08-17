//
//  NSInvocation+MXUtils.m
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "NSInvocation+MXUtils.h"

@implementation NSInvocation (MXUtils)

- (MXTypeEncoding*)typeEncodingForParameterAtIndex:(NSUInteger)index
{
    // must increment past the first 2 implicit parameters
    index += 2;
    
    const char* type = [self.methodSignature getArgumentTypeAtIndex:index];
    return [[MXTypeEncoding alloc] initWithTypeEncoding:type];
}

- (NSObject*)objectValueForParameterAtIndex:(NSUInteger)index
{
    // must increment past the first 2 implicit parameters
    index += 2;
    
    NSObject* __unsafe_unretained obj = nil;
    [self getArgument:&obj atIndex:index];
    
    return obj;
}

- (NSString*)stringValueForParameterAtIndex:(NSUInteger)index
{
    MXTypeEncoding* encoding = [self typeEncodingForParameterAtIndex:index];
    
    // must increment past the first 2 implicit parameters
    index += 2;
    
    switch (encoding.encodingClass) {
        case MXObjectTypeEncodingClass: {
            NSObject* __unsafe_unretained obj = nil;
            [self getArgument:&obj atIndex:index];
            return [NSString stringWithFormat:@"%@", obj];
        }
            
        case MXIntegerNumberTypeEncodingClass: {
            long long value = 0;
            [self getArgument:&value atIndex:index];
            return [NSString stringWithFormat:[encoding formatSpecifier], value];
        }
            
        case MXFloatingNumberTypeEncodingClass: {
            double value = 0;
            [self getArgument:&value atIndex:index];
            return [NSString stringWithFormat:[encoding formatSpecifier], value];
        }
            
        case MXOtherTypeEncodingClass: {
            NSAssert(NO, @"Unrecognized parameter type");
            return nil;
        }
    }
}


@end
