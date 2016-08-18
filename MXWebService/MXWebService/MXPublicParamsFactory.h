//
//  MXPublicParamsFactory.h
//  MXWebService
//
//  Created by lly on 16/8/18.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  请求公共参数生产
 */
@protocol MXPublicParamsDelegate <NSObject>

- (NSDictionary *)pubicParams;

@end

@protocol MXPublicParamsFactoryDelegate <NSObject>

- (id<MXPublicParamsDelegate>)pubicParamsDelegate;
- (void)setPubicParamsDelegate:(id<MXPublicParamsDelegate>)pubicParamsDelegate;

@end


@interface MXPublicParamsFactory : NSObject<MXPublicParamsFactoryDelegate>

@end
