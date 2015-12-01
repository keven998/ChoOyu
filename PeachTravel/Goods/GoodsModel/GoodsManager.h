//
//  GoodsManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsDetailModel.h"

@interface GoodsManager : NSObject

/* *******商品详情*********** */

/**
*  加商品详情
*
*  @param goodsId    商品 ID
*  @param completion
*/
+ (void)asyncLoadGoodsDetailWithGoodsId:(NSInteger)goodsId completionBlock:(void (^) (BOOL isSuccess, NSDictionary *goodsDetailJson, GoodsDetailModel *goodsDetail))completion;

/********商品列表************/

/**
 *  加载某个城市的商品列表
 *
 *  @param cityId     城市 id
 *  @param completion 返回数据
 */
+ (void)asyncLoadGoodsOfCity:(NSString *)cityId completionBlock:(void (^)(BOOL isSuccess, NSArray *goodsList))completion;

/**
 *  加载某个城市的商品列表，添加分类纬度
 *
 *  @param cityId     城市 id
 *  @param category   分类
 *  @param completion 
 */
+ (void)asyncLoadGoodsOfCity:(NSString *)cityId category:(NSString *)category completionBlock:(void (^)(BOOL isSuccess, NSArray *goodsList))completion;

/**
 *  加载某个城市的商品列表，添加分类纬度，添加排序纬度
 *
 *  @param cityId     城市 ID
 *  @param category   分类
 *  @param sortType   排序类型
 *  @param sort       正序 or 逆序
 *  @param completion
 */
+ (void)asyncLoadGoodsOfCity:(NSString *)cityId category:(NSString *)category sortBy:(NSString *)sortType sortValue:(NSString *)sortValue completionBlock:(void (^)(BOOL isSuccess, NSArray *goodsList))completion;

/**
 *  加载某个城市商品列表，添加分类维度， 添加排序维度，添加分页机制
 *
 *  @param cityId     城市 ID
 *  @param category   分类
 *  @param sortType   排序类型
 *  @param sortValue       正序 or 逆序
 *  @param startIndex 从第几个开始加载
 *  @param count   加载数量
 *  @param completion
 */
+ (void)asyncLoadGoodsOfCity:(NSString *)cityId category:(NSString *)category sortBy:(NSString *)sortType sortValue:(NSString *)sortValue startIndex:(NSInteger)startIndex count:(NSUInteger)count completionBlock:(void (^)(BOOL, NSArray *))completion;


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

/**
 *  收藏商品接口
 *
 *  @param goodsId
 *  @param isFavorite
 *  @param completion
 */
+ (void)asyncFavoriteGoodsWithGoodsId:(NSString *)goodsId isFavorite:(BOOL)isFavorite completionBlock:(void (^)(BOOL isSuccess))completion;


+ (void)asyncLoadGoodsCategoryOfLocality:(NSString *)localityId completionBlock:(void(^)(BOOL isSuccess, NSArray<NSString *>* categoryList))completion;

@end
