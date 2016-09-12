//
//  MXMethodDescription.h
//  MXEngine
//
//  Created by lly on 16/6/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXParameterizeResult.h"
@protocol MXDataConverter;

@interface MXMethodDescription : NSObject

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
                                  converter:(id<MXDataConverter>)converter
                                      error:(NSError**)error;

- (MXParameterizeResult<NSString*>*)parameterizedPathForInvocation:(NSInvocation*)invocation
                                                     withConverter:(id<MXDataConverter>)converter
                                                             error:(NSError**)error;

- (MXParameterizeResult<NSDictionary*>*)parameterizedHeadersForInvocation:(NSInvocation*)invocation
                                                            withConverter:(id<MXDataConverter>)converter
                                                                    error:(NSError**)error;

- (MXParameterizeResult*)bodyForInvocation:(NSInvocation*)invocation
                             withConverter:(id<MXDataConverter>)converter
                                     error:(NSError**)error;



@end
