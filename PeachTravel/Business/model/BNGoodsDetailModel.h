//
//  BNGoodsDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailModel.h"

typedef enum : NSUInteger {
    kOnSale = 1,
    kReviewing,
    kOffSale,
} BNGoodsStatus;

@interface BNGoodsDetailModel : GoodsDetailModel

@property (nonatomic) BNGoodsStatus goodsStatus;
@property (nonatomic) BOOL isPackageExpire;   //套餐信息是否过期
@property (nonatomic, copy, readonly) NSString *goodsStatusDesc;

@end
