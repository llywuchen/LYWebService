//
//  MXProtocolImpl.h
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXWebService.h"

@protocol MXDataConverterFactoryDelegate;

@interface MXProtocolImpl : NSObject

@property(nonatomic,strong) Protocol* protocol;
@property(nonatomic,strong) NSURL* endPoint;
@property (nonatomic,assign) MXPublicParamsType publicParamsType;
@property (nonatomic,strong) NSDictionary *publicParamsDic;
@property(nonatomic,strong) NSDictionary* methodDescriptions;
@property(nonatomic,strong) id<MXDataConverterFactoryDelegate> converterFactory;

@end
