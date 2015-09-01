//
//  ExpertManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExpertManager : NSObject

/**
 *  异步从网上加载达人列表
 *
 *  @param areaId   达人所属地区的 ID
 *  @param page
 *  @param pageSize
 *  @param completionBlock 数据回掉， 包含请求是否成功，达人列表信息
 */
+ (void)asyncLoadExpertsWithAreaId:(NSString *)areaId page:(NSInteger)page pageSize:(NSInteger)pageSize completionBlock:(void(^)(BOOL isSuccess, NSArray *expertsArray))completionBlock;

/**
 *  申请成为达人
 *
 *  @param phoneNumber
 *  @param completionBlock  
 */
+ (void)asyncRequest2BeAnExpert:(NSString *)phoneNumber completionBlock:(void(^)(BOOL isSuccess))completionBlock;

@end
