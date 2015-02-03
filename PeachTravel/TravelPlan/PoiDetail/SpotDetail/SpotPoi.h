//
//  SpotPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotPoi : NSObject

@property (nonatomic, copy) NSString *spotId;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, copy) NSString *priceDesc;
@property (nonatomic, copy) NSString *travelMonth;
@property (nonatomic, copy) NSString *openTime;
@property (nonatomic, copy) NSString *timeCostStr;
@property (nonatomic, copy) NSString *trafficInfoUrl;
@property (nonatomic, copy) NSString *guideUrl;
@property (nonatomic, copy) NSString *tipsUrl;
@property (nonatomic) BOOL isMyFavorite;
@property (nonatomic) float rating;

@property (nonatomic) double lat;
@property (nonatomic) double lng;

- (id)initWithJson:(id)json;

@end
