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

+ (void)asyncLoadRecommendPersonalTailorData:(void (^) (BOOL isSuccess, NSArray<PTDetailModel *> *resultList))completion;

+ (void)asyncMakePersonalTailorWithPTModel:(PTDetailModel *)ptDetailModel completionBlock:(void (^) (BOOL isSuccess, PTDetailModel *ptDetailModel))completion;


@end
