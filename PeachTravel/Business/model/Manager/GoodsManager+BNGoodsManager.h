//
//  GoodsManager+BNGoodsManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/8/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsManager.h"
#import "BNGoodsDetailModel.h"

@interface GoodsManager (BNGoodsManager)

/**
 *  加载某个店铺的商品列表
 *
 *  @param storeId    店铺 ID
 *  @param startIndex
 *  @param count
 *  @param completion
 */
+ (void)asyncLoadGoodsOfStore:(NSInteger)storeId goodsStatus:(BNGoodsStatus)status startIndex:(NSInteger)startIndex count:(NSUInteger)count completionBlock:(void (^)(BOOL isSuccess, NSArray *goodsList))completion;

/**
 *  加载商家版本的商品详情
 *
 *  @param goodsId
 *  @param completion   
 */
+ (void)asyncLoadBNGoodsDetailWithGoodsId:(NSInteger)goodsId completionBlock:(void (^)(BOOL isSuccess, NSDictionary *goodsDic, BNGoodsDetailModel *goodsDetail))completion;

/**
 *  下架商品
 *
 *  @param goodsId    商品 ID
 *  @param completion
 */
+ (void)asyncDisableGoods:(NSInteger)goodsId completionBlock:(void(^)(BOOL isSuccess, NSString *errDesc))completion;

/**
 *  上架商品
 *
 *  @param goodsId    商品 ID
 *  @param completion 
 */
+ (void)asyncOnsaleGoods:(NSInteger)goodsId completionBlock:(void(^)(BOOL isSuccess, NSString *errDesc))completion;

@end
