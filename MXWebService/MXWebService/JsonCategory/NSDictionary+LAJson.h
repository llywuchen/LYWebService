//
//  NSDictionary+LAJson.h
//  Pods
//
//  Created by LakeR on 16/6/29.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (LAJson)

- (NSString *)jsonString;

- (id)__toDictionary;

@end
