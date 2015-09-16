//
//  GuiderDistributeTools.h
//  PeachTravel
//
//  Created by 王聪 on 15/8/26.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//  达人列表工具类

#import <Foundation/Foundation.h>
@interface GuiderDistributeTools : NSObject

// 获得标题数组
+ (NSArray *)titleArray;

/**
 *  获得大洲的 code
 *
 *  @return 
 */
+ (NSArray *)continentCodeArray;


#pragma mark - 请求网络数据
+ (void)guiderStatusWithParam:(NSDictionary *)param success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

@end
