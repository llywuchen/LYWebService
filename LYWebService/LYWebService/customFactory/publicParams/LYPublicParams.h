//
//  LYPublicParams.h
//  LYWebService
//
//  Created by lly on 2016/12/28.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  请求公共参数生产
 */
@protocol LYPublicParams <NSObject>

- (NSDictionary *)pubicParams;

@end


@interface LYPublicParamsDefault : NSObject <LYPublicParams>

- (NSDictionary *)pubicParams;

- (NSDictionary *)oldPubicParams;

@end
