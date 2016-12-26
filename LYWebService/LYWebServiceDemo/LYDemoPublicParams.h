//
//  LYDemoPublicParams.h
//  LYWebService
//
//  Created by lly on 16/8/18.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYDemoPublicParams : NSObject <LYPublicParamsDelegate>
- (NSDictionary *)pubicParams;

+ (NSDictionary *)oldPubicParams;
@end
