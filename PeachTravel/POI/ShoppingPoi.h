//
//  ShoppingPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "SuperPoi.h"

@interface ShoppingPoi : SuperPoi

@property (nonatomic, strong) NSArray *recommends;

- (id)initWithJson:(id)json;


@end