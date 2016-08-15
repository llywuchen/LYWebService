//
//  MXJsonConverterFactory.m
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "MXGomePlusConverter.h"

@implementation MXDataConverterFactory

- (id<MXDataConverter>)converter
{
    return [[MXGomePlusConverter alloc] init];
}


@end
