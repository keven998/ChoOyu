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
#import "GoodsPackageModel.h"

@interface GoodsDetailModel : NSObject

@property (nonatomic, copy) NSString *goodsId;
@property (nonatomic, copy) NSString *goodsName;
@property (nonatomic, copy) NSString *goodsDesc;
@property (nonatomic) float primePrice;
@property (nonatomic, strong) TaoziImage *image;
@property (nonatomic) float currentPrice;
@property (nonatomic, strong) NSArray<NSString *> *tags;
@property (nonatomic, strong) BusinessMoel *business;
@property (nonatomic, strong) StoreDetailModel *store;
@property (nonatomic) float rating;
@property (nonatomic) NSInteger saleCount;
@property (nonatomic, strong) NSArray<GoodsPackageModel *> *packages;
- (id)initWithJson:(id)json;

@end
