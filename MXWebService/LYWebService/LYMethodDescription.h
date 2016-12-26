//
//  LYMethodDescription.h
//  LYWebService
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYParameterizeResult.h"
@protocol LYDataConverter;

@interface LYMethodDescription : NSObject

@property(nonatomic,strong,readonly) NSArray* parameterNames;
@property(nonatomic,strong,readonly) NSString* resultType;
@property(nonatomic,strong,readonly) NSDictionary* annotations;
@property(nonatomic,strong,readonly) NSString* taskType;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (NSString*)httpMethod;

- (Class)taskClass;

- (Class)resultConversionClass;

- (BOOL)isFormURLEncoded;

- (NSString*)valueForParameterAtIndex:(NSUInteger)index
                             withInvocation:(NSInvocation*)invocation
                                  converter:(id<LYDataConverter>)converter
                                      error:(NSError**)error;

- (LYParameterizeResult<NSString*>*)parameterizedPathForInvocation:(NSInvocation*)invocation
                                                     withConverter:(id<LYDataConverter>)converter
                                                             error:(NSError**)error;

- (LYParameterizeResult<NSDictionary*>*)parameterizedHeadersForInvocation:(NSInvocation*)invocation
                                                            withConverter:(id<LYDataConverter>)converter
                                                                    error:(NSError**)error;

- (LYParameterizeResult*)bodyForInvocation:(NSInvocation*)invocation
                             withConverter:(id<LYDataConverter>)converter
                                     error:(NSError**)error;



@end
