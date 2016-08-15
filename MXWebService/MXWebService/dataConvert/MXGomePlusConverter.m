//
//  MXJsonConverter.m
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "MXGomePlusConverter.h"
#import "MXDictionryConvertable.h"

@implementation MXGomePlusConverter

- (id)convertData:(NSDictionary *)data toObjectOfClass:(Class)cls error:(NSError**)error
{
    if (cls == [NSString class]) {
        // I guess if they want a string, just return that directly
//        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        //todo franklin
        return [data objectForKey:@"message"];
    }
    
    id jsonObject = [data objectForKey:@"data"];//[NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    
    if (error && *error) {
        return nil;
    }
    
    return [self convertJSONObject:jsonObject toObjectOfClass:cls error:error];
}

- (id)convertJSONObject:(id)jsonObject toObjectOfClass:(Class)cls error:(NSError**)error
{
    if (cls == nil || cls == [NSDictionary class]) {
        //如果需要的是数组或者字典 直接返回 客户化转换
        return jsonObject;
        
    }else if (cls == [NSArray class]){
        return jsonObject;
    }
    
    else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        return [[cls alloc] initWithDictionary:jsonObject];
        
    } else {//jsonarray
        NSMutableArray* result = [[NSMutableArray alloc] init];
        
        for (id element in jsonObject) {
            id convertedValue = [[cls alloc] initWithDictionary:element];
            [result addObject:convertedValue];
        }
        
        return result.copy;
    }
}

- (NSData*)convertObjectToData:(id)object error:(NSError**)error
{
    id result = [self convertObjectToJSONValue:object];
    
    return [NSJSONSerialization dataWithJSONObject:result options:0 error:error];
}

- (id)convertObjectToJSONValue:(id)object
{
    if ([NSJSONSerialization isValidJSONObject:object]) {
        return object;
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray* result = [[NSMutableArray alloc] init];
        
        for (id element in object) {
            id convertedObject = [self convertObjectToJSONValue:element];
            [result addObject:convertedObject];
        }
        
        return result.copy;
        
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
        
        for (id key in object) {
            id convertedObject = [self convertObjectToJSONValue:[object objectForKey:key]];
            result[key] = convertedObject;
        }
        
        return result.copy;
    } else {
        return [object toDictionary];
    }
}

- (NSString*)convertObjectToString:(id)object error:(NSError**)error
{
    return [[NSString alloc] initWithData:[self convertObjectToData:object error:error] encoding:NSUTF8StringEncoding];
}


@end
