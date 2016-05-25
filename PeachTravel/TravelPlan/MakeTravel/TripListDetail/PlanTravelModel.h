//
//  PlanTravelModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 5/19/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlanTravelModel : NSObject

@property (nonatomic, copy) NSString *trafficName;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *startPointName;
@property (nonatomic, copy) NSString *endPointName;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *endDate;

- (id)initWithJson:(id)json;

@end
