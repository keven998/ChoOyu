//
//  ShoppingOfCity.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ShoppingOfCity.h"
#import "ShoppingPoi.h"

@implementation ShoppingOfCity

- (id)initWithJson:(id)json
{
    if (self = [super initWithJson:json]) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id restaurantDic in [json objectForKey:@"poiList"]) {
            ShoppingPoi *poi = [[ShoppingPoi alloc] initWithJson:restaurantDic];
            [tempArray addObject:poi];
        }
        _shoppingList = tempArray;
    }
    return self;
}


@end
