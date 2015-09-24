//
//  MyGuideSummary.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/29/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyGuideSummary : NSObject<NSCoding>

@property (nonatomic, copy) NSString *guideId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic) long long updateTime;
@property (nonatomic, copy) NSString *updateTimeStr;
@property (nonatomic) NSInteger dayCount;
@property (nonatomic, copy) NSString *status;
- (id)initWithJson:(id)json;


@end
