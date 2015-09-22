//
//  PoiSearchManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/22/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoiSearchManager : NSObject

+ (void)searchPoiWithKeyword:(NSString *)keyWord andSearchCount:(NSInteger)count andPoiType:(TZPoiType)poiType completionBlock:(void (^)(BOOL, NSArray *))completion;

@end
