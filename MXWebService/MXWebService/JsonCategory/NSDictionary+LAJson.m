//
//  NSDictionary+LAJson.m
//  Pods
//
//  Created by LakeR on 16/6/29.
//
//

#import "NSDictionary+LAJson.h"
//#import "LAReformatter.h"

@implementation NSDictionary (LAJson)

//TODO: convert custom Object to Dictionary in NSDictionary
- (NSString *)jsonString{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self __toDictionary] options:NSJSONWritingPrettyPrinted error:&error];
    if (!error) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSLog(@"Convert to  json String error : %@",error);
    return nil;
}

- (id)__toDictionary{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (id key in [self allKeys]) {
        id object = self[key];
        if([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]){
            [dic setValue:object forKey:key];
        }else if([object respondsToSelector:@selector(__toDictionary)]){
            id value = [object __toDictionary];
            if(!value){
                NSLog(@"can not convert %@ to dictionary!",object);
                return nil;
            }
            [dic setValue:value forKey:key];
        }else if([object respondsToSelector:@selector(convertToDictionary:)]){
            NSError *error = nil;
            id value = nil;//[object convertToDictionary:&error];
            if(value == nil || error){
                NSLog(@"can not convert %@ to dictionary! \n error : %@ ",object,error);
                return nil;
            }
            [dic setValue:value forKey:key];
        }else {
            NSLog(@"array contains unsupport value %@",object);
            return nil;
        }
    }
    return dic;
}

@end
