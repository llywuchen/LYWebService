//
//  MXJsonConverterFactory.m
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "MXGomePlusConverter.h"
@interface MXDataConverterFactory(){
    id<MXDataConverter> _converter;
}

@end
@implementation MXDataConverterFactory

#pragma mark --geter and setter
- (id<MXDataConverter>)converter
{
    if(!_converter){
        return [[MXGomePlusConverter alloc] init];
    }
    return _converter;
}

- (void)setConverter:(id<MXDataConverter>)converter{
    _converter = converter;
}


@end
