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
@property (nonatomic, copy) NSString *objectId;  
@property (nonatomic, copy) NSString *goodsName;
@property (nonatomic, copy) NSString *goodsDesc;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) float primePrice;
@property (nonatomic) float currentPrice;
@property (nonatomic, copy, readonly) NSString *formatPrimePrice;
@property (nonatomic, copy, readonly) NSString *formatCurrentPrice;
@property (nonatomic, strong) NSArray<TaoziImage *> *images;
@property (nonatomic, copy) TaoziImage *coverImage;
@property (nonatomic, strong) NSArray<NSString *> *tags;
@property (nonatomic, strong) StoreDetailModel *store;
@property (nonatomic) float rating;
@property (nonatomic) NSInteger saleCount;
@property (nonatomic) long goodsVersion;
@property (nonatomic, strong) NSArray<GoodsPackageModel *> *packages;
@property (nonatomic, strong) CityDestinationPoi *locality;
@property (nonatomic, copy) NSString *shareUrl;


- (id)initWithJson:(id)json;

@end
