//
//  LYDataConverterFactory.m
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "LYDataConverter.h"

@implementation LYDefaultDataConverter

#pragma mark - result data convert

- (id)convertData:(id)data toObjectOfClass:(Class)cls error:(NSError* *)error
{
    id jsonObject = nil;
    if([data isKindOfClass:[NSData class]]){
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
        if (error && *error) {
            return nil;
        }
    }else if ([data isKindOfClass:[NSDictionary class]]){
        jsonObject = [data objectForKey:@"data"];
        if (cls == [NSString class]) {
            return [data objectForKey:@"message"];
        }

        if([jsonObject isKindOfClass:[NSDictionary class]]&&((NSDictionary *)jsonObject).count==1){
            return [self convertJSONObject:((NSDictionary *)jsonObject).allValues[0] toObjectOfClass:cls error:error];
        }
        return [self convertJSONObject:jsonObject toObjectOfClass:cls error:error];
    }
    return nil;
    
}

- (id)convertJSONObject:(id)jsonObject toObjectOfClass:(Class)cls error:(NSError* *)error
{
    if (cls == nil || cls == [NSDictionary class] || cls == [NSArray class]) {
        return jsonObject;
        
    }else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        return [[cls alloc] initWithDictionary:jsonObject];
        
    }else {//jsonarray
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (id element in jsonObject) {
            id convertedValue = [[cls alloc] initWithDictionary:element];
            [result addObject:convertedValue];
        }
        return result.copy;
    }
}

#pragma mark - error convert
- (NSString*)convertErrorData:(id)errorData forResponse:(NSHTTPURLResponse*)response{
    if([errorData isKindOfClass:[NSString class]]){
        return errorData;
    }else if ([errorData isKindOfClass:[NSDictionary class]]){
        return [errorData objectForKey:@"message"];
    }else{
        return nil;
    }
}

- (NSString *)convertError:(NSError *)error forResponse:(NSHTTPURLResponse *)response{
    NSDictionary *dic = [error.userInfo objectForKey:@"responseObject"];
    NSString *errorMsg = [dic objectForKey:@"message"];
    if(errorMsg.length==0){
        errorMsg = @"网络错误";
    }
    //    if (error.domain == NSCocoaErrorDomain)
    //    {
    ////                switch ([error code]) {
    ////                    case ASIConnectionFailureErrorType:
    ////                        errorMsg = @"无法连接到网络";
    ////                        break;
    ////                    case ASIRequestTimedOutErrorType:
    ////                        errorMsg = @"访问超时";
    ////                        break;
    ////                    case ASIAuthenticationErrorType:
    ////                        errorMsg = @"服务器身份验证失败";
    ////                        break;
    ////                    case ASIRequestCancelledErrorType:
    ////                        errorMsg = @"服务器请求已取消";
    ////                        break;
    ////                    case ASIUnableToCreateRequestErrorType:
    ////                        errorMsg = @"无法创建服务器请求";
    ////                        break;
    ////                    case ASIInternalErrorWhileBuildingRequestType:
    ////                        errorMsg = @"服务器请求创建异常";
    ////                        break;
    ////                    case ASIInternalErrorWhileApplyingCredentialsType:
    ////                        errorMsg = @"服务器请求异常";
    ////                        break;
    ////                    case ASIFileManagementError:
    ////                        errorMsg = @"服务器请求异常";
    ////                        break;
    ////                    case ASIUnhandledExceptionError:
    ////                        errorMsg = @"未知请求异常异常";
    ////                        break;
    ////                    default:
    ////                        errorMsg = @"服务器故障或网络链接失败！";
    ////                        break;
    ////                }
    //    }
    return errorMsg;
}

#pragma mark -
#pragma mark - request params convert
- (NSData *)convertObjectToData:(id)object error:(NSError* *)error
{
    id result = [self convertObjectToJSONValue:object];
    
    return [NSJSONSerialization dataWithJSONObject:result options:0 error:error];
}

- (id)convertObjectToJSONValue:(id)object
{
    if ([NSJSONSerialization isValidJSONObject:object]) {
        return object;
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        for (id element in object) {
            id convertedObject = [self convertObjectToJSONValue:element];
            [result addObject:convertedObject];
        }
        
        return result.copy;
        
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        
        for (id key in object) {
            id convertedObject = [self convertObjectToJSONValue:[object objectForKey:key]];
            result[key] = convertedObject;
        }
        
        return result.copy;
    } else {
        return [object jsonObject];
    }
}

- (NSString *)convertObjectToString:(id)object error:(NSError* *)error
{
    return [[NSString alloc] initWithData:[self convertObjectToData:object error:error] encoding:NSUTF8StringEncoding];
}
@end
