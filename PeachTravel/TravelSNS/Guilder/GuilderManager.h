//
//  GuilderManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuilderManager : NSObject

/**
 *  异步从网上加载达人列表
 *
 *  @param areaId   达人所属地区的 ID
 *  @param page
 *  @param pageSize
 *  @param completionBlock 数据回掉， 包含请求是否成功，达人列表信息
 */
+ (void)asyncLoadGuidersWithAreaId:(NSString *)areaId page:(NSInteger)page pageSize:(NSInteger)pageSize completionBlock:(void(^)(BOOL isSuccess, NSArray *guiderArray))completionBlock;


@end
