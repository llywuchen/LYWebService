//
//  NSInvocation+LYUtils.h
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LYTypeEncoding.h"

@interface NSInvocation (LYUtils)

- (LYTypeEncoding*)typeEncodingForParameterAtIndex:(NSUInteger)index;

- (NSObject*)objectValueForParameterAtIndex:(NSUInteger)index;

- (NSString*)valueForParameterAtIndex:(NSUInteger)index;

@end
