//
//  LYCustomFactory.m
//  LYWebService
//
//  Created by lly on 2016/12/28.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import "LYCustomFactory.h"

@interface LYCustomFactory (){
    id<LYDataConverter> _dataconverter;
    id<LYPublicParams> _pubicParams;
}


@end

@implementation LYCustomFactory

#pragma mark --geter and setter
- (id<LYDataConverter>)newDataConverter
{
    if(!_dataconverter){
        return [[LYDefaultDataConverter alloc] init];
    }else{
        return [[_dataconverter.class alloc]init];
    }
}

- (void)setDataConverter:(id<LYDataConverter>)converter{
    _dataconverter = converter;
}


- (NSDictionary *)newPubicParams{
    if(!_pubicParams){
        return nil;
    }else{
        return [_pubicParams pubicParams];
    }
}

- (void)setPubicParams:(id<LYPublicParams>)pubicParams{
    _pubicParams = pubicParams;
}


@end
