//
//  RecentSearchTool.m
//  PeachTravel
//
//  Created by 王聪 on 15/8/10.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "RecentSearchTool.h"
#import "FMDatabase.h"

@implementation RecentSearchTool

// 数据库实例
static FMDatabase * _db;

+ (void)initialize
{
    // 1.获得数据库文件的路径
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * filename = [doc stringByAppendingPathComponent:@"SpiData.sqlite"];
    
    // 2.得到数据库
    _db = [FMDatabase databaseWithPath:filename];
    
    // 3.打开数据库
    if ([_db open]) {
        // 4.创表
        BOOL result = [_db executeUpdate:@"create table if not exists recent_search(id integer primary key autoincrement,search_content text not null);"];
        if (result) {
            NSLog(@"创表成功");
        }else{
            NSLog(@"创表失败");
        }
    }
}


// 将搜索结果插入到数据库中
+ (void)saveRecentSearchToSpoiData:(NSString *)recentSearch
{
    
    
    if ([_db open]) {
        // 根据请求参数查询数据
        FMResultSet * resultSet = nil;
        
        //    int spoiDataNumber = 10;
        
        resultSet = [_db executeQuery:@"select * from recent_search order by id desc"];
        
        // 遍历查询结果
        while ([resultSet next]) {
            NSString * recent_search = [resultSet objectForColumnName:@"search_content"];
            
            if ([recentSearch isEqualToString:recent_search]) {
                // 如果数据库中存在这个数据,就将它移除
                [_db executeUpdate:@"delete from recent_search where search_content = ?;",recent_search];
            }
        }
        
    }

    
    BOOL result = [_db executeUpdate:@"insert into recent_search(search_content) values(?);",recentSearch];
    
    if (result) {
        NSLog(@"插入数据成功");
    }else{
        NSLog(@"插入数据失败");
    }
}

// 读取数据库中的元素
+ (NSArray *)getAllRecentSearchResult{
    
   NSMutableArray * recentSearchResult = [NSMutableArray array];
    
    if ([_db open]) {
        // 根据请求参数查询数据
        FMResultSet * resultSet = nil;
        
        //    int spoiDataNumber = 10;
        
        resultSet = [_db executeQuery:@"select * from recent_search order by id desc"];
//        resultSet = [_db executeQuery:@"select * from recent_search"];
        
        
        // 遍历查询结果
        while ([resultSet next]) {
            NSString * recent_search = [resultSet objectForColumnName:@"search_content"];
            
            // 添加到数组中
            [recentSearchResult addObject:recent_search];
        }

    }
    
      return recentSearchResult;

}

@end
