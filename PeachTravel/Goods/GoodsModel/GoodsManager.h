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

@end
