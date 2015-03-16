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
    }
    return self;
}

@end
