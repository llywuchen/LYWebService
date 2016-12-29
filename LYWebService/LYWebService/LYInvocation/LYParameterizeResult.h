//
//  LYParameterizeResult.h
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYParameterizeResult<ObjectType> : NSObject

@property(nonatomic,strong,readonly) ObjectType result;
@property(nonatomic,strong,readonly) NSSet *consumedParameters;

- (instancetype)initWithResult:(ObjectType)result
consumedParameters:(NSSet<NSString *> *)consumedParameters;

@end
