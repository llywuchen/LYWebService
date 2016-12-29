//
//  LYCustomFactory.h
//  LYWebService
//
//  Created by lly on 2016/12/28.
//  Copyright © 2016年 meixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYDataConverter.h"
#import "LYPublicParams.h"

#pragma mark - LYPublicParamsFactoryDelegate
@protocol LYPublicParamsFactoryDelegate <NSObject>

- (NSDictionary *)newPubicParams;
- (void)setPubicParams:(id<LYPublicParams>)pubicParams;

@end

#pragma mark - LYDataConverterFactoryDelegate
@protocol LYDataConverterFactoryDelegate <NSObject>

@required
- (id<LYDataConverter>)newDataConverter;
- (void)setDataConverter:(id<LYDataConverter>)dataConverter;

@end

#pragma mark - LYCustomFactory
@interface LYCustomFactory : NSObject<LYPublicParamsFactoryDelegate,LYDataConverterFactoryDelegate>

@end
