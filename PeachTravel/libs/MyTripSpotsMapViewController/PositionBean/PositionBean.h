//
//  PositionBean.h
//  lvxingpai
//
//  Created by liangpengshuai on 14-8-19.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PositionBean : NSObject
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, copy) NSString *poiName;
@property (nonatomic, copy) NSString *poiId;
@property (nonatomic, copy) NSString *poiPhone;
//用来按顺序显示
@property (nonatomic, assign) NSUInteger poiOrder;
@end
