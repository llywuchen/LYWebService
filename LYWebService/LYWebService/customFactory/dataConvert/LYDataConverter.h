//
//  LYDataConverterFactory.h
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYDictionryConvertable.h"

#pragma mark -----------LYDataConverter-------------------
@protocol LYDataConverter <NSObject>

- (id)convertData:(id)data toObjectOfClass:(Class)cls error:(NSError**)error;

- (NSData*)convertObjectToData:(id)object error:(NSError**)error;

- (NSString*)convertError:(NSError *)error forResponse:(NSHTTPURLResponse*)response;

@optional

- (NSString*)convertErrorData:(id)errorData forResponse:(NSHTTPURLResponse*)response;

- (NSString*)convertObjectToString:(id)object error:(NSError**)error;

@end



#pragma mark ------------------------------
@interface LYDefaultDataConverter : NSObject <LYDataConverter>

- (id)convertJSONObject:(id)jsonObject toObjectOfClass:(Class)cls error:(NSError**)error;

- (NSString*)convertError:(NSError *)error forResponse:(NSHTTPURLResponse*)response;

- (NSError*)convertErrorData:(id)errorData forResponse:(NSHTTPURLResponse*)response;
@end


