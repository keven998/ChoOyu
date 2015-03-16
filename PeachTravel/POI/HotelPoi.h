//
//  HotelPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "SuperPoi.h"

@interface HotelPoi : SuperPoi

@property (nonatomic, copy) NSString *bookUrl;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic, copy) NSString *priceDesc;

- (id)initWithJson:(id)json;

@end
