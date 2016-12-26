//
//  LYPublicParamsFactory.m
//  LYWebService
//
//  Created by lly on 16/8/18.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import "LYPublicParamsFactory.h"

@interface LYPublicParamsFactory (){
    id<LYPublicParamsDelegate> _pubicParamsDelegate;
}

@end

@implementation LYPublicParamsFactory

- (id<LYPublicParamsDelegate>)pubicParamsDelegate{
    if(!_pubicParamsDelegate){
        return nil;
    }
    return _pubicParamsDelegate;
}

- (void)setPubicParamsDelegate:(id<LYPublicParamsDelegate>)pubicParamsDelegate{
    _pubicParamsDelegate = pubicParamsDelegate;
}

@end
