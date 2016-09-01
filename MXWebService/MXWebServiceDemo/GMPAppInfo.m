//
//  GMPAppInfo.m
//  GMBuy
//
//  Created by 刘继坤 on 16/8/14.
//  Copyright © 2016年 cn. All rights reserved.
//

#import "GMPAppInfo.h"


@implementation GMPAppInfo

+ (NSString*) getAppId {
    return @"001";
}

+ (NSString*) getDevice {
    
    return @"";
}

+ (NSString*) getAppVersion {
    NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    return appVersion == nil ? @"1.0.0" : appVersion;
}

+ (NSString*) getAppBuild {
    NSString* build = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    return build == nil ? @"1.0.0.1" : build;
}
// CCPVVvvYYZZZXXXX
+ (NSString*) getFrom {
    NSString *versionCode = [self getVersionCode];
    return [NSString stringWithFormat:@"%@%@%@%@%@%@", ProductCode, PlatformCode, versionCode, ChannelCategoryCode, ChannelCode , @"0000"];
}

+ (NSString *) getVersionCode {
    NSString *appVersion = [GMPAppInfo getAppVersion];
    if(appVersion == nil) return @"0000";
    NSArray *versions = [appVersion componentsSeparatedByString:@"."];
    if([versions count] != 3) return @"0000";
    NSString *version = [NSString stringWithFormat:@"%@%@%@", versions[0], versions[1], versions[2]];
    return version.length <4 ? [NSString stringWithFormat:@"0%@", version] : version;
}

+ (NSString*) getOsVersion {
    return [[UIDevice currentDevice] systemVersion];
}
@end
