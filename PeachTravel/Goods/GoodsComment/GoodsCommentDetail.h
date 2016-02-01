//
//  GoodsCommentDetail.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/22/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsDetailModel.h"

@interface GoodsCommentDetail : NSObject

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;  //评价的商品
@property (nonatomic, strong) GoodsPackageModel *selectedPackage;  //选中的套餐

@property (nonatomic, strong) NSArray <TaoziImage *>* images;
@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, copy) NSString *contents;
@property (nonatomic) float rating;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, strong) FrendModel *commentUser;   //评价人

- (id)initWithJson:(id)json;

@end
