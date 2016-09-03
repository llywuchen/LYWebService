//
//  MXGomePlusPublicParams.m
//  MXWebService
//
//  Created by lly on 16/8/18.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import "MXGomePlusPublicParams.h"
#import "GMPAppInfo.h"

#pragma mark -----old params
//下载渠道代号:100 iOS AppStore官方渠道 200 iOS In-House企业渠道
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

@implementation MXGomePlusPublicParams
- (NSDictionary *)pubicParams{
    NSDictionary * dic = [self.class commonRequestDic];
    return dic;
}


+(NSDictionary*)commonRequestDic{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [self getDevice], @"X-Gomeplus-Device",
                         [NSString stringWithFormat:@"%@/%@", [GMPAppInfo getAppId], [GMPAppInfo getFrom]], @"X-Gomeplus-App",
                         [self getUserAgent], @"X-Gomeplus-User-Agent",
                         [GMPAppInfo getAppVersion], @"appVersion",
                         [GMPAppInfo getFrom], @"X-Gomeplus-PubPlat",
                         [self.class deviceType], @"phoneType",
                         @"0",@"X-Gomeplus-Login-Token",
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
    //FROM字段 参照: http://redmine.gomeo2omx.cn/projects/mobile/wiki/统计相关
    
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
    [MXWebClientInstance.requestSerializer setValue:loginToken forHTTPHeaderField:@"X-Gomeplus-Login-Token"];
    //    _loginToken = loginToken;
}

+ (void) setUserId:(NSString *)userId {
    [MXWebClientInstance.requestSerializer setValue:userId forHTTPHeaderField:@"X-Gomeplus-User-Id"];
    //    _userId = userId;
}

+ (void) setNet:(NSString *)netType {
    [MXWebClientInstance.requestSerializer setValue:netType forHTTPHeaderField:@"X-Gomeplus-Net"];
}

//------------------- public method end -------------------

//------------------- private method start ------------------
+ (NSString*) getDevice {
    //OSType/OSVersion/DeviceModel/DeviceId
    return [NSString stringWithFormat:@"%@/%@/%@/%@", GMPOSType, [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model],  [[[UIDevice currentDevice] identifierForVendor] UUIDString] ];
}

+ (NSString*) getUserAgent {
    return [NSString stringWithFormat:@"%@/%@", @"gomeplus-iOS", [GMPAppInfo getAppVersion]];
}

@end
