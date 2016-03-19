//
//  StoreDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityDestinationPoi.h"
#import "PeachTravel-swift.h"

@interface StoreDetailModel : NSObject

@property (nonatomic) NSInteger storeId;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, strong) NSArray<NSString *> *languages;      //语言
@property (nonatomic, strong) NSArray<NSString *> *serviceTags;    //服务标签
@property (nonatomic, strong) NSArray<NSString *> *qualifications;           //卖家资质 (认证卖家等)
@property (nonatomic, strong) NSArray<CityDestinationPoi *> *serviceZone;  //服务城市

@property (nonatomic) NSInteger totalOrderCnt;
@property (nonatomic) float totalSales;
@property (nonatomic, copy, readonly) NSString *formatTotalSales;

@property (nonatomic) NSInteger pendingOrderCnt;

@property (nonatomic, strong) BusinessMoel *business;

- (id)initWithJson:(id)json;

@end
