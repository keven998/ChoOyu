//
//  SpotPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "SuperPoi.h"

@interface SpotPoi : SuperPoi

@property (nonatomic, copy) NSString *timeCostStr;
@property (nonatomic, copy) NSString *bookUrl;
@property (nonatomic, copy) NSString *travelMonth;

@property (nonatomic, copy) NSString *trafficInfo;
@property (nonatomic, copy) NSString *trafficInfoUrl;

@property (nonatomic, copy) NSString *guideInfo;
@property (nonatomic, copy) NSString *guideUrl;

@property (nonatomic, copy) NSString *tipsInfo;
@property (nonatomic, copy) NSString *tipsUrl;
- (id)initWithJson:(id)json;

@end