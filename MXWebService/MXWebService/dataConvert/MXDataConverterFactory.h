//
//  MXJsonConverterFactory.h
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MXDataConverter <NSObject>

- (id)convertData:(id)data toObjectOfClass:(Class)cls error:(NSError**)error;

- (NSData*)convertObjectToData:(id)object error:(NSError**)error;

@optional

- (NSError*)convertErrorData:(id)errorData forResponse:(NSHTTPURLResponse*)response;

- (NSString*)convertObjectToString:(id)object error:(NSError**)error;

@end


@protocol MXDataConverterFactoryDelegate <NSObject>

- (id<MXDataConverter>)converter;

@end


@interface MXDataConverterFactory : NSObject<MXDataConverterFactoryDelegate>

@end
