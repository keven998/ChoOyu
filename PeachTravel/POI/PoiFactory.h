//
//  PoiFactory.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/19/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuperPoi.h"

@interface PoiFactory : NSObject

+ (SuperPoi *)poiWithPoiType:(TZPoiType)poiType andJson:(id)json;

+ (SuperPoi *)poiWithPoiTypeDesc:(NSString *)poiTypeDesc andJson:(id)json;

+ (SuperPoi *)poiWithJson:(id)json;

@end
