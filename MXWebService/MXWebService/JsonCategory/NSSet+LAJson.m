//
//  NSSet+LAJson.m
//  Pods
//
//  Created by LakeR on 16/7/5.
//
//

#import "NSSet+LAJson.h"
#import "NSArray+LAJson.h"

@implementation NSSet (LAJson)

//TODO: convert custom Object to Dictionary in NSSet
- (NSString *)jsonString{
    return [[self allObjects] jsonString];
}


- (id)__toDictionary{
    return [[self allObjects] __toDictionary];
}



@end
