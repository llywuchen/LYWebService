//
//  GMPAppInfo.h
//  GMBuy
//
//  Created by 刘继坤 on 16/8/14.
//  Copyright © 2016年 cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#define iOSClientOsType @"2"
#define ProductCode @"01"
#define PlatformCode @"2"
#define ChannelCategoryCode @"00"
#define ChannelCode @"100"

@interface GMPAppInfo : NSObject
+ (NSString*) getDevice;
+ (NSString*) getAppId;
+ (NSString*) getAppVersion;
+ (NSString*) getAppBuild;
+ (NSString*) getFrom;
+ (NSString*) getOsVersion;
@end
