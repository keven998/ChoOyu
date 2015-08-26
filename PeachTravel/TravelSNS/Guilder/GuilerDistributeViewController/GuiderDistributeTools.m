//
//  GuiderDistributeTools.m
//  PeachTravel
//
//  Created by 王聪 on 15/8/26.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuiderDistributeTools.h"
#import "GuiderDistribute.h"
#import "GuiderDistributeContinent.h"
#import "MJExtension.h"
@interface GuiderDistributeTools ()

@property (nonatomic, strong) NSArray *guiderArray;

@end

@implementation GuiderDistributeTools

/**
 *  懒加载模型数组
 */
- (NSArray *)guiderArray
{
    if (_guiderArray == nil) {
        _guiderArray = [NSArray array];
    }
    return _guiderArray;
}

// 获得标题数组
+ (NSArray *)getTitleArray {
    NSArray * titleArray = @[@"亚洲",@"欧洲",@"美洲",@"大洋洲",@"非洲"];
    return titleArray;
}


#pragma mark - 请求网络数据
+ (void)guiderStatusWithParam:(NSDictionary *)param success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    // 1.获取请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // 2.请求链接
    NSString * url = API_GET_TOUR_GULIDER;
    
    NSLog(@"%@",url);
    
    // 3.发送Get请求
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@",responseObject);
        /**
         *  获取字典数组
         */
        NSArray * resultArray = responseObject[@"result"];
        
        /**
         *  将字典数组转换成模型数组
         */
        NSArray *guiderArray = [NSArray array];
        guiderArray = [GuiderDistribute objectArrayWithKeyValuesArray:resultArray];
        NSArray *dataSource = [GuiderDistributeTools revertGuiderListToGroup:guiderArray];
        
        NSLog(@"%@",dataSource);
        if (success) {
            success(dataSource);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 打印失败信息
        NSLog(@"%@",error);
        if (failure) {
            failure(error);
        };
    }];
    
}


// 处理guiderArray数组,将一个数组转换成分组数组
+ (NSArray *)revertGuiderListToGroup:(NSArray *)list
{
    NSArray *guiderList = [[list mutableCopy] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        GuiderDistribute *guiderOne = obj1;
        GuiderDistribute *guiderTwo = obj2;
        
        NSComparisonResult result = guiderOne.rank > guiderTwo.rank;
        return result == NSOrderedDescending;
    }];
    
    NSArray *titleArray = [GuiderDistributeTools getTitleArray];
    
    // 1.创建一个分组数组,里面存放了多少组数据
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < titleArray.count; i++) {
        
        NSMutableArray * array = [NSMutableArray array];
        [dataSource addObject:array];
    }
    
    // 2.遍历数组
    for (GuiderDistribute * distrubute in guiderList) {
        int i = 0;
        GuiderDistributeContinent * guilderContinent = distrubute.continents;
        for (NSString * title in titleArray)
        {
            if ([guilderContinent.zhName isEqualToString:title]) {
                NSMutableArray *array = dataSource[i];
                [array addObject:distrubute];
                break;
            }
            i++;
        }
    }
    
    // 3.过滤数组为空的元素
    for (int i = 0; i < dataSource.count; i++) {
        NSArray * guilderArray = dataSource[i];
        if (guilderArray.count == 0) {
            [dataSource removeObject:guilderArray];
        }
    }
    
    return dataSource;
}

@end
