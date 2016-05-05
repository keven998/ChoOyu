//
//  PersonalTailorManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTDetailModel.h"
#import "CityDestinationPoi.h"

@interface PersonalTailorManager : NSObject

+ (void)asyncLoadPTServerCountWithCompletionBlock:(void (^) (BOOL isSuccess, NSInteger count))completion;

+ (void)asyncLoadRecommendPersonalTailorDataWithStartIndex:(NSInteger)index pageCount:(NSInteger)count completionBlock:(void (^) (BOOL isSuccess, NSArray<PTDetailModel *> *resultList))completion;

+ (void)asyncMakePersonalTailorWithPTModel:(PTDetailModel *)ptDetailModel completionBlock:(void (^) (BOOL isSuccess, PTDetailModel *ptDetailModel))completion;

+ (void)asyncMakePlanForPTWithPtId:(NSString *)ptId content:(NSString *)content totalPrice:(float)price guideList:(NSArray *)guideList completionBlock:(void (^)(BOOL))completion;

+ (void)asyncLoadUsrePTDataWithUserId:(NSInteger)userId index:(NSInteger)index pageCount:(NSInteger)count completionBlock:(void (^) (BOOL isSuccess, NSArray<PTDetailModel *> *resultList))completion;

+ (void)asyncLoadPTDetailDataWithItemId:(NSString *)itemId completionBlock:(void (^) (BOOL isSuccess, PTDetailModel *ptDetail))completion;

+ (void)asyncTakePersonalTailor:(NSString *)itemId completionBlock:(void (^) (BOOL isSuccess))completion;

+ (void)asyncLoadSellerServerPTDataWithUserId:(NSInteger)userId index:(NSInteger)index pageCount:(NSInteger)count  completionBlock:(void (^) (BOOL isSuccess, NSArray<PTDetailModel *> *resultList))completion;

+ (void)asyncLoadSellerServerCitysWithUserId:(NSInteger)userId completionBlock:(void (^) (BOOL isSuccess, NSArray<CityDestinationPoi *> *resultList))completion;

+ (void)asyncSelectPlan:(NSInteger)planId withPtId:(NSString *)ptId completionBlock:(void (^) (BOOL isSuccess))completion;

+ (void)asyncBNRefuseRefundMoneyOrderWithPtId:(NSString *)ptId target:(NSString *)target leaveMessage:(NSString *)message completionBlock:(void (^)(BOOL isSuccess, NSString *errorStr))completion;

+ (void)asyncBNAgreeRefundMoneyOrderWithPtId:(NSString *)ptId refundMoney:(float)money target:(NSString *)target leaveMessage:(NSString *)message completionBlock:(void (^)(BOOL isSuccess, NSString *errorStr))completion;

+ (void)asyncApplyRefundMoneyOrderWithPtId:(NSString *)ptId target:(NSString *)target leaveMessage:(NSString *)message completionBlock:(void (^)(BOOL isSuccess, NSString *errorStr))completion;

@end
