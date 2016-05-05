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
#import "PTPlanDetailModel.h"
#import "PeachTravel-swift.h"

@interface PTDetailModel : NSObject

@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *service;
@property (nonatomic, strong) NSArray *serviceList;

@property (nonatomic, strong) NSArray *topicList;
@property (nonatomic, copy) NSString *topic;
@property (nonatomic, copy) NSString *departureDate;
@property (nonatomic) NSTimeInterval createTime;
@property (nonatomic, copy, readonly) NSString *createTimeStr;

@property (nonatomic, copy) NSString *status;


@property (nonatomic, strong) NSArray<CityDestinationPoi *> *destinations;
@property (nonatomic, strong) CityDestinationPoi *fromCity;

@property (nonatomic, strong) NSArray<PTPlanDetailModel *> *plans;
@property (nonatomic, strong) NSArray<FrendModel *> *takers;  //抢单人
@property (nonatomic) NSInteger takersCnt;  //抢单人数量

@property (nonatomic, strong) FrendModel *consumer;   //发单人

@property (nonatomic, strong) PTPlanDetailModel *selectPlan;  //已选择的方案

@property (nonatomic) BOOL hasRequestRefundMoney;  //是否申请退款

@property (nonatomic) float totalPrice;
@property (nonatomic) BOOL planPaid;  //方案是否支付

@property (nonatomic) float earnestMoney;
@property (nonatomic) BOOL bountyPaid;  //定金是否支付

@property (nonatomic) NSInteger timeCost;
@property (nonatomic) NSInteger memberCount;

@property (nonatomic) float budget;
@property (nonatomic, strong) OrderTravelerInfoModel *contact;
@property (nonatomic, copy) NSString *memo;
@property (nonatomic) BOOL hasChild;
@property (nonatomic) BOOL hasOldMan;
@property (nonatomic, copy) NSString *demand;
@property (nonatomic, copy) NSString *extraDemand;

- (id)initWithJson:(id)json;

@end
