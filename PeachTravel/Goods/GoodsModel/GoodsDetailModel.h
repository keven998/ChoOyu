//
//  GoodsDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachTravel-swift.h"
#import "StoreDetailModel.h"
#import "CityDestinationPoi.h"
#import "GoodsPackageModel.h"

@interface GoodsDetailModel : NSObject

@property (nonatomic) NSInteger goodsId;
@property (nonatomic, copy) NSString *goodsName;
@property (nonatomic, copy) NSString *goodsDesc;
@property (nonatomic) float primePrice;
@property (nonatomic) float currentPrice;
@property (nonatomic, strong) TaoziImage *image;
@property (nonatomic, copy) TaoziImage *coverImage;
@property (nonatomic, strong) NSArray<NSString *> *tags;
@property (nonatomic, strong) BusinessMoel *business;
@property (nonatomic, strong) StoreDetailModel *store;
@property (nonatomic) float rating;
@property (nonatomic) NSInteger saleCount;
@property (nonatomic, strong) NSArray<GoodsPackageModel *> *packages;
@property (nonatomic, strong) CityDestinationPoi *locality;

- (id)initWithJson:(id)json;

@end
