//
//  GuiderDistribute.m
//  PeachTravel
//
//  Created by 王聪 on 15/7/15.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuiderDistribute.h"
#import "MJExtension.h"
#import "GuiderDistributeContinent.h"

@implementation GuiderDistribute

- (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"ID":@"id"};
}

// 将数组中得字典转换成模型
- (NSDictionary *)objectClassInArray
{
    return @{@"continents":[GuiderDistributeContinent class]};
}

@end
