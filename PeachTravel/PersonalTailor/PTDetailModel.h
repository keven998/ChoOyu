//
//  PTDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityDestinationPoi.h"
#import "OrderTravelerInfoModel.h"

@interface PTDetailModel : NSObject

@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *service;
@property (nonatomic, strong) NSArray *serviceList;

@property (nonatomic, strong) NSArray *topicList;
@property (nonatomic, copy) NSString *topic;
@property (nonatomic, copy) NSString *departureDate;
@property (nonatomic) NSTimeInterval createTime;
@property (nonatomic, copy, readonly) NSString *createTimeStr;

@property (nonatomic, strong) NSArray<CityDestinationPoi *> *destinations;
@property (nonatomic, strong) CityDestinationPoi *fromCity;

@property (nonatomic) float totalPrice;
@property (nonatomic) float earnestMoney;

@property (nonatomic) NSInteger timeCost;
@property (nonatomic) NSInteger grabCount;
@property (nonatomic) NSInteger numberCount;

@property (nonatomic) float budget;
@property (nonatomic) BOOL paied;
@property (nonatomic, strong) OrderTravelerInfoModel *contact;
@property (nonatomic, copy) NSString *memo;
@property (nonatomic) BOOL hasChild;
@property (nonatomic) BOOL hasOldMan;
@property (nonatomic, copy) NSString *demand;
@property (nonatomic, copy) NSString *extraDemand;

- (id)initWithJson:(id)json;

@end
