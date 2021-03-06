//
//  RestaurantPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "RestaurantPoi.h"

@implementation RestaurantPoi


- (id)initWithJson:(id)json
{
    if (self = [super initWithJson:json]) {
        self.poiType = kRestaurantPoi;
        self.typeDesc = @"restaurant";
        self.poiTypeName = @"美食";
    }
    return self;
}

- (NSDictionary *)enCodeAllDataToDictionary
{
    NSMutableDictionary *retDic = [[super enCodeAllDataToDictionary] mutableCopy];
    [retDic safeSetObject:super.priceDesc forKey:@"priceDesc"];
    
    return retDic;
    
}
@end
