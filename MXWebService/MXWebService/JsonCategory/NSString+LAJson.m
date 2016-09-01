//
//  NSString+LAJson.m
//  Pods
//
//  Created by LakeR on 16/6/29.
//
//

#import "NSString+LAJson.h"

@implementation NSString (LAJson)

-(id)toObject{
    NSError *jsonError = nil;
    id json = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                              options:NSJSONReadingMutableContainers
                                                error:&jsonError];
    if (!jsonError) {
        return json;
    }
    NSLog(@"Convert to  json object error : %@",jsonError);
    return nil;
}

@end
