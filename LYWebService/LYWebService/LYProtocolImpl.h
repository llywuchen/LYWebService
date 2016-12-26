//
//  LYProtocolImpl.h
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYWebService.h"

@protocol LYDataConverterFactoryDelegate;

@interface LYProtocolImpl : NSObject

@property(nonatomic,strong) Protocol* protocol;
@property(nonatomic,strong) NSURL* endPoint;
@property (nonatomic,assign) LYPublicParamsType publicParamsType;
@property (nonatomic,strong) NSDictionary *publicParamsDic;
@property(nonatomic,strong) NSDictionary* methodDescriptions;
@property(nonatomic,strong) id<LYDataConverterFactoryDelegate> converterFactory;

@end
