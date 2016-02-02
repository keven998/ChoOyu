//
//  UserCommentManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 2/1/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsCommentDetail.h"

@interface UserCommentManager : NSObject


/**
 *  对商品发表一个评价
 *
 *  @param goodsId    商品 id
 *  @param orderId    订单 id
 *  @param value      分值 0~1之间
 *  @param contents    评价内容
 *  @param completion
 */
+ (void)asyncMakeCommentWithGoodsId:(NSInteger)goodsId orderId:(NSInteger)orderId ratingValue:(float)value andContent:(NSString *)contents isAnonymous:(BOOL)anonymous completionBlock:(void (^)(BOOL isSuccess))completion;

/**
 *  加载一个商品的评论列表
 *
 *  @param goodsId
 *  @param completion
 */
+ (void)asyncLoadGoodsCommentsWithGoodsId:(NSInteger)goodsId completionBlock:(void(^)(BOOL isSuccess, NSArray <GoodsCommentDetail *> *commentsList))completion;


@end
