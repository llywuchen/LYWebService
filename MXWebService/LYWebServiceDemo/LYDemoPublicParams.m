//
//  LYDemoPublicParams.m
//  LYWebService
//
//  Created by lly on 16/8/18.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "LYDemoPublicParams.h"

#pragma mark -----old params
#define channel @"200"
#define platForm 1
#define appType 1
#define mac @"00000000"
#define IP @"0.0.0.0"
#define clientOsVersion [[UIDevice currentDevice] systemVersion]
#define appVersion [NSString stringWithFormat:@"%@%@",@"v",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]

#pragma mark ------------------------

#define GMPOSType  @"iOS"
// from iOS 7.0, Apple will return below mac address for all device for
// security reason
#define GMPMac @"02:00:00:00:00:00"

@implementation LYDemoPublicParams
- (NSDictionary *)pubicParams{
    NSDictionary * dic = [self.class commonRequestDic];
    return dic;
}


+(NSDictionary*)commonRequestDic{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [self getDevice], @"device",
                         [NSString stringWithFormat:@"%@/%@", @"appid", @"app-from"], @"app",
                         [self getUserAgent], @"user-Agent",
                         @"appVersion", @"appVersion",
                         @"approm", @"PubPlat",
                         [self.class deviceType], @"phoneType",
                         @"",@"login-Token",
                         nil];
    
    return dic;
}

+ (NSDictionary *)oldPubicParams{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @(0), @"userId",
                         [NSNumber numberWithInt:platForm], @"clientOs",
                         clientOsVersion, @"clientOsVersion",
                         [NSNumber numberWithInt:appType], @"appType",
                         appVersion, @"appVersion",
                         [self.class deviceType], @"phoneType",
                         IP ,@"ip",
                         @"3G", @"netType",
                         mac, @"mac",
                         [self.class deviceToken].length > 0 ? [self.class deviceToken] : @"0", @"devId",
                         @"otherDevInfo", @"otherDevInfo",
                         @"0",@"loginToken",
                         [self.class getFrom],@"pubPlat",
                         nil];
    
    return dic;
}

+ (NSString *)deviceType
{
    NSString *type = [UIDevice currentDevice].model;
    return type;
}

+ (NSString *)deviceToken
{
    
    static NSString *token = nil;
    if (nil == token)
    {
        token = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
        if (token == nil)
        {
            token = @"0";
        }
    }
    return token;
}
+ (NSString *)getFrom
{
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    // 拼 产品代号
    [tempStr appendFormat:@"01"];
    // 拼平台代号
    [tempStr appendFormat:@"2"];
    // 拼客户端版本号
    //    [tempStr appendFormat:@"%@",];
    NSString *bundel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSArray *ary = [bundel componentsSeparatedByString:@"."];
    if ([ary[0] integerValue] < 10) {
        [tempStr appendFormat:@"0%@",ary[0]];
    }else
    {
        [tempStr appendFormat:@"%@",ary[0]];
    }
    [tempStr appendFormat:@"%@",ary[1]];
    [tempStr appendFormat:@"%@",ary[2]];
    
    // 拼渠道分类
    [tempStr appendFormat:@"00"];
    // 拼渠道代号
    [tempStr appendFormat:channel];
    // 预留字段
    [tempStr appendFormat:@"0000"];
    return [tempStr copy];
}


#pragma mark ------------------------


+ (BOOL) isNetworkAvailable {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL) isMobileNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

+ (BOOL) isWifiNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}


#pragma mark getter
//------------------- public method start -------------------
+ (void)setLoginToken:(NSString *)loginToken {
    [LYWebClientInstance.requestSerializer setValue:loginToken forHTTPHeaderField:@"login-Token"];
    //    _loginToken = loginToken;
}

+ (void) setUserId:(NSString *)userId {
    [LYWebClientInstance.requestSerializer setValue:userId forHTTPHeaderField:@"user-Id"];
    //    _userId = userId;
}

+ (void) setNet:(NSString *)netType {
    [LYWebClientInstance.requestSerializer setValue:netType forHTTPHeaderField:@"Net"];
}

//------------------- public method end -------------------

//------------------- private method start ------------------
+ (NSString*) getDevice {
    //OSType/OSVersion/DeviceModel/DeviceId
    return [NSString stringWithFormat:@"%@/%@/%@/%@", GMPOSType, [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model],  [[[UIDevice currentDevice] identifierForVendor] UUIDString] ];
}

+ (NSString*) getUserAgent {
    return [NSString stringWithFormat:@"%@/%@", @"app-iOS", @"appVersion"];
}

@end
