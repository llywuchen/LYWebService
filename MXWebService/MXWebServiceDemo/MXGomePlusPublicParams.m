//
//  MXGomePlusPublicParams.m
//  MXWebService
//
//  Created by lly on 16/8/18.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import "MXGomePlusPublicParams.h"
#import "GMPAppInfo.h"

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
