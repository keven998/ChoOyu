//
//  GoodsManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsDetailModel.h"
#import "OrderDetailModel.h"

@interface GoodsManager : NSObject

/* *******商品详情*********** */

/**
*  加商品详情
*
*  @param goodsId    商品 ID
*  @param completion
*/
+ (void)asyncLoadGoodsDetailWithGoodsId:(NSInteger)goodsId completionBlock:(void (^) (BOOL isSuccess, NSDictionary *goodsDetailJson, GoodsDetailModel *goodsDetail))completion;

/**
 *  加载指定版本的商品详情
 *
 *  @param goodsId
 *  @param version
 *  @param completion 
 */
+ (void)asyncLoadGoodsDetailWithGoodsId:(NSInteger)goodsId version:(long)version completionBlock:(void (^)(BOOL isSuccess, NSDictionary *goodsDetailJson, GoodsDetailModel *goodsDetail))completion;

/********商品列表************/

/**
 *  加载某个城市的商品列表
 *
 *  @param cityId     城市 id
 *  @param startIndex 从第几个开始加载
 *  @param count   加载数量
 *  @param completion 返回数据
 */
+ (void)asyncLoadGoodsOfCity:(NSString *)cityId startIndex:(NSInteger)startIndex count:(NSUInteger)count completionBlock:(void (^)(BOOL isSuccess, NSArray *goodsList))completion;

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

/**
 *  加载某个店铺的商品列表
 *
 *  @param storeId    店铺 ID
 *  @param startIndex
 *  @param count
 *  @param completion 
 */
+ (void)asyncLoadGoodsOfStore:(NSInteger)storeId startIndex:(NSInteger)startIndex count:(NSUInteger)count completionBlock:(void (^)(BOOL isSuccess, NSArray *goodsList))completion;

/**
 *  搜索商品
 *
 *  @param searchKey  关键词
 *  @param completion 
 */
+ (void)asyncSearchGoodsWithSearchKey:(NSString *)searchKey completionBlock:(void (^)(BOOL isSuccess, NSArray *goodsList))completion;

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

+ (void)asyncLoadGoodsCategoryOfLocality:(NSString *)localityId completionBlock:(void(^)(BOOL isSuccess, NSArray<NSString *>* categoryList))completion;


/**
 *  收藏商品接口
 *
 *  @param objectId
 *  @param isFavorite
 *  @param completion
 */
+ (void)asyncFavoriteGoodsWithGoodsObjectId:(NSString *)objectId isFavorite:(BOOL)isFavorite completionBlock:(void (^)(BOOL isSuccess))completion;

/**
 *  获取用户的收藏列表
 *
 *  @param userId     用户 userId
 *  @param completion
 */
+ (void)asyncLoadFavoriteGoodsOfUser:(NSInteger)userId  completionBlock:(void (^)(BOOL isSuccess, NSArray *goodsList))completion;

@end
