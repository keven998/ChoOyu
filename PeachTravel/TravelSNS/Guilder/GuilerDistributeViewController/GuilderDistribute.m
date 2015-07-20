//
//  GuilderDistribute.m
//  PeachTravel
//
//  Created by 王聪 on 15/7/15.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuilderDistribute.h"
#import "MJExtension.h"
#import "GuilderDistributeContinent.h"
@implementation GuilderDistribute

- (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"ID":@"id"};
}

// 将数组中得字典转换成模型
- (NSDictionary *)objectClassInArray
{
    return @{@"continents":[GuilderDistributeContinent class]};
}

@end
