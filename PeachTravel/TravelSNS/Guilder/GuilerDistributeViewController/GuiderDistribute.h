//
//  GuiderDistribute.h
//  PeachTravel
//
//  Created by 王聪 on 15/7/15.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GuiderDistributeContinent;

@interface GuiderDistribute : NSObject

@property (nonatomic, copy)NSString * ID;

@property (nonatomic, strong)NSArray * images;

@property (nonatomic, copy)NSString * zhName;

@property (nonatomic, copy)NSString *enName;

@property (nonatomic, copy)NSString * code;

@property (nonatomic) NSInteger rank;

@property (nonatomic)NSInteger expertCnt;

@property (nonatomic, strong)GuiderDistributeContinent * continents;

@end
