//
//  MXPublicParamsFactory.m
//  MXWebService
//
//  Created by lly on 16/8/18.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import "MXPublicParamsFactory.h"

@interface MXPublicParamsFactory (){
    id<MXPublicParamsDelegate> _pubicParamsDelegate;
}

@end

@implementation MXPublicParamsFactory

- (id<MXPublicParamsDelegate>)pubicParamsDelegate{
    if(!_pubicParamsDelegate){
        return nil;
    }
    return _pubicParamsDelegate;
}

- (void)setPubicParamsDelegate:(id<MXPublicParamsDelegate>)pubicParamsDelegate{
    _pubicParamsDelegate = pubicParamsDelegate;
}

@end
