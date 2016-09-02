//
//  MXDictionryConvertable.h
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MXDictionryConvertable <NSObject>

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (id)jsonObject;
- (NSData *)jsonData;

@end
