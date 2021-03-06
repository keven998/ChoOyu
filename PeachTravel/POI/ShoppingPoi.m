//
//  ShoppingPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ShoppingPoi.h"

@implementation ShoppingPoi

- (id)initWithJson:(id)json
{
    if (self = [super initWithJson:json]) {
        self.poiType = kShoppingPoi;
        self.poiTypeName = @"购物";
        self.typeDesc = @"shopping";
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
