//
//  NSInvocation+MXUtils.h
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MXTypeEncoding;

@interface NSInvocation (MXUtils)

- (MXTypeEncoding*)typeEncodingForParameterAtIndex:(NSUInteger)index;

- (NSObject*)objectValueForParameterAtIndex:(NSUInteger)index;

- (NSString*)stringValueForParameterAtIndex:(NSUInteger)index;

@end
