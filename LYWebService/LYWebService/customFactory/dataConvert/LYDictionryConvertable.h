//
//  LYDictionryConvertable.h
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LYDictionryConvertable <NSObject>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@optional
- (id)jsonObject;

@end
