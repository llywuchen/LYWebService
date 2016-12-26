//
//  LYPublicParamsFactory.h
//  LYWebService
//
//  Created by lly on 16/8/18.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  请求公共参数生产
 */
@protocol LYPublicParamsDelegate <NSObject>

- (NSDictionary *)pubicParams;

@end

@protocol LYPublicParamsFactoryDelegate <NSObject>

- (id<LYPublicParamsDelegate>)pubicParamsDelegate;
- (void)setPubicParamsDelegate:(id<LYPublicParamsDelegate>)pubicParamsDelegate;

@end


@interface LYPublicParamsFactory : NSObject<LYPublicParamsFactoryDelegate>

@end
