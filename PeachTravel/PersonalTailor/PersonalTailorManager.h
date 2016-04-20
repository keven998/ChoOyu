//
//  PersonalTailorManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTDetailModel.h"

@interface PersonalTailorManager : NSObject

+ (void)asyncLoadRecommendPersonalTailorDataWithStartIndex:(NSInteger)index pageCount:(NSInteger)count completionBlock:(void (^) (BOOL isSuccess, NSArray<PTDetailModel *> *resultList))completion;

+ (void)asyncMakePersonalTailorWithPTModel:(PTDetailModel *)ptDetailModel completionBlock:(void (^) (BOOL isSuccess, PTDetailModel *ptDetailModel))completion;

+ (void)asyncMakePlanForPTWithPtId:(NSString  *)ptId content:(NSString *)content totalPrice:(NSInteger)price guideList:(NSArray *)guideList completionBlock:(void (^) (BOOL isSuccess))completion;

+ (void)asyncLoadUsrePTDataWithUserId:(NSInteger)userId completionBlock:(void (^) (BOOL isSuccess, NSArray<PTDetailModel *> *resultList))completion;

+ (void)asyncLoadPTDetailDataWithItemId:(NSString *)itemId completionBlock:(void (^) (BOOL isSuccess, PTDetailModel *ptDetail))completion;

+ (void)asyncTakePersonalTailor:(NSString *)itemId completionBlock:(void (^) (BOOL isSuccess))completion;


@end
