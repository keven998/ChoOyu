//
//  RestaurantPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantPoi : NSObject

@property (nonatomic, copy) NSString *restaurantId;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, copy) NSString *priceDesc;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *recommends;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic) NSInteger commentCount;
@property (nonatomic) float rating;

- (id)initWithJson:(id)json;
@end
