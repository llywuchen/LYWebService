//
//  MXParameterizeResult.m
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "MXParameterizeResult.h"

@implementation MXParameterizeResult

- (instancetype)initWithResult:(id)result
            consumedParameters:(NSSet<NSString*>*)consumedParameters
{
    self = [super init];
    
    if (self) {
        _result = result;
        _consumedParameters = consumedParameters.copy;
    }
    
    return self;
}

@end
