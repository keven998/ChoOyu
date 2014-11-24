//
//  ShoppingPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShoppingPoi : NSObject
@property (nonatomic, copy) NSString *shoppingId;
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

- (id)initWithJson:(id)json;
@end
