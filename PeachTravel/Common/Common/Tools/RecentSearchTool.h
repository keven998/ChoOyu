//
//  RecentSearchTool.h
//  PeachTravel
//
//  Created by 王聪 on 15/8/10.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentSearchTool : NSObject

// 将搜索结果插入到数据库中
+ (void)saveRecentSearchToSpoiData:(NSString *)recentSearch;

// 读取数据库中的元素
+ (NSArray *)getAllRecentSearchResult;

@end
