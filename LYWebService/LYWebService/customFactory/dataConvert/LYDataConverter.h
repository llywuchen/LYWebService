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

/**
 * you can custom data converter with extens LYDefaultDataConverter
 * and overWrite methods in LYDataConverter, you can also use the defult implements .
 */

@protocol LYDataConverter <NSObject>

// request params convert,if your request params is custom class.
- (NSData *)convertObjectToData:(id)object error:(NSError* *)error;
- (NSString *)convertObjectToString:(id)object error:(NSError* *)error;
- (id)convertObjectToJSONValue:(id)object;

// request data convert
- (id)convertData:(id)data toObjectOfClass:(Class)cls error:(NSError* *)error;
- (id)convertJSONObject:(id)jsonObject toObjectOfClass:(Class)cls error:(NSError* *)error;

// request error convert
- (NSString *)convertError:(NSError *)error forResponse:(NSHTTPURLResponse *)response;
- (NSString *)convertErrorData:(id)errorData forResponse:(NSHTTPURLResponse *)response;


@end



#pragma mark ------------------------------
@interface LYDefaultDataConverter : NSObject <LYDataConverter>

@end


