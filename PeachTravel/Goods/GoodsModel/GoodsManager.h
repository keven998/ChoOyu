//
//  GoodsManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsManager : NSObject

/**
 *  加载某个城市的商品列表
 *
 *  @param cityId     城市 id
 *  @param completion 返回数据
 */
+ (void)asyncLoadGoodsOfCity:(NSString *)cityId completionBlock:(void (^)(BOOL isSuccess, NSArray *goodsList))completion;


/*********** 商品推荐相关 **************/

/**
 *  获取推荐的商品列表
 *  goodsList 的结构类型为:   {
                                @"title" : @"小编推荐",
                                @"goodsList": NSArray<GoodDetailModel *>
                            }
 *  @param completion 
 */
+ (void)asyncLoadRecommendGoodsWithCompletionBlock:(void (^)(BOOL isSuccess, NSArray<NSDictionary *> *goodsList))completion;


@end
