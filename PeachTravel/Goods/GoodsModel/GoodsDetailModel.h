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
#import "GoodsCommentDetail.h"

@interface GoodsDetailModel : NSObject

@property (nonatomic) NSInteger goodsId;
@property (nonatomic, copy) NSString *objectId;  
@property (nonatomic, copy) NSString *goodsName;
@property (nonatomic, copy) NSString *goodsDescSummary;
@property (nonatomic, copy) NSString *goodsDescBody;
@property (nonatomic, copy) NSString *goodsFeeDescSummary;
@property (nonatomic, copy) NSString *goodsBookDescSummary;
@property (nonatomic, copy) NSString *goodsQuitDescSummary;
@property (nonatomic, copy) NSString *goodsTrafficDescSummary;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *timecost;

@property (nonatomic) BOOL isFavorite;
@property (nonatomic) float primePrice;
@property (nonatomic) float currentPrice;
@property (nonatomic, copy, readonly) NSString *formatPrimePrice;
@property (nonatomic, copy, readonly) NSString *formatCurrentPrice;
@property (nonatomic, strong) CountryModel *country;
@property (nonatomic, strong) CityDestinationPoi *locality;
@property (nonatomic, strong) NSArray<TaoziImage *> *images;
@property (nonatomic, copy) TaoziImage *coverImage;
@property (nonatomic, strong) NSArray<NSString *> *category;
@property (nonatomic, strong) NSArray<NSString *> *tags;
@property (nonatomic, strong) StoreDetailModel *store;
@property (nonatomic) float rating;
@property (nonatomic) NSInteger saleCount;
@property (nonatomic) long goodsVersion;
@property (nonatomic, strong) NSArray<GoodsPackageModel *> *packages;
@property (nonatomic, copy) NSString *shareUrl;

@property (nonatomic, copy) NSString *allDescUrl;
@property (nonatomic, copy) NSString *allBookTipsUrl;
@property (nonatomic, copy) NSString *allBookQuitUrl;
@property (nonatomic, copy) NSString *allTrafficUrl;

@property (nonatomic) NSInteger commentCnt;
@property (nonatomic, strong) NSArray<GoodsCommentDetail *> *commentList;

- (id)initWithJson:(id)json;

@end
