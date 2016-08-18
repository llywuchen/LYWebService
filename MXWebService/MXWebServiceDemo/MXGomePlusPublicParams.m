//
//  MXGomePlusPublicParams.m
//  MXWebService
//
//  Created by lly on 16/8/18.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import "MXGomePlusPublicParams.h"

//下载渠道代号:100 iOS AppStore官方渠道 200 iOS In-House企业渠道
#define channel @"200"
#define platForm 1
#define appType 1
#define mac @"00000000"
#define IP @"0.0.0.0"
#define clientOsVersion [[UIDevice currentDevice] systemVersion]
#define appVersion [NSString stringWithFormat:@"%@%@",@"v",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]

@implementation MXGomePlusPublicParams
- (NSDictionary *)pubicParams{
    NSDictionary * dic = [self.class commonRequestDic];
//    NSMutableDictionary * paraDic = [[NSMutableDictionary alloc]initWithCapacity:8];
//    NSString * device = [NSString stringWithFormat:@"%@/%@/%@/%@",@"IOS",dic[@"clientOsVersion"],dic[@"phoneType"],dic[@"devId"]];
//    [paraDic setObject:device forKey:@"device"];
//    
//    [paraDic setObject:dic[@"appVersion"] forKey:@"appVersion"];
//    [paraDic setObject:dic[@"netType"] forKey:@"net"];
//    [paraDic setObject:dic[@"loginToken"] forKey:@"loginToken"];
//    if (dic[@"userId"]) {
//        [paraDic setObject:dic[@"userId"] forKey:@"userId"];
//    }
//    //非必传--暂时不传。
//    //    [paraDic setObject:nil forKey:@"accessToken"];
//    //    [paraDic setObject:nil forKey:@"traceId"];
//    //    [paraDic setObject:nil forKey:@"jsonp"];
//    NSString * appString = [NSString stringWithFormat:@"001/1111111111111"];
//    [paraDic setObject:appString forKey:@"app"];
//    if (dic[@"ip"]) {
//        [paraDic setObject:dic[@"ip"] forKey:@"ip"];
//    }
//    if (dic[@"mac"]) {
//        [paraDic setObject:dic[@"mac"] forKey:@"mac"];
//    }
//    return paraDic;
    
    return dic;
}


+(NSDictionary*)commonRequestDic{
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

@end
