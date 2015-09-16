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

+ (NSArray *)continentCodeArray {
    NSArray * continentCode = @[@"AS",@"EU",@"NA", @"SA", @"OA", @"AF"];
    return continentCode;
}

// 获得标题数组
+ (NSArray *)titleArray {
    NSArray * titleArray = @[@"亚洲",@"欧洲",@"北美洲", @"南美洲", @"大洋洲",@"非洲"];
    return titleArray;
}

#pragma mark - 请求网络数据

+ (void)guiderStatusWithParam:(NSDictionary *)param success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString * url = API_GET_TOUR_GULIDER;
    
    NSLog(@"%@",url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@",responseObject);
        NSArray * resultArray = responseObject[@"result"];
        NSLog(@"%@",resultArray);
        NSArray *guiderArray = [NSArray array];
        guiderArray = [GuiderDistribute objectArrayWithKeyValuesArray:resultArray];
        NSArray *dataSource = [GuiderDistributeTools revertGuiderListToGroup:guiderArray];
        
        NSLog(@"%@",dataSource);
        if (success) {
            success(dataSource);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        if (failure) {
            failure(error);
        };
    }];
    
}

/**
 *  处理guiderArray数组,将一个数组转换成分组数组
 *
 *  @param list
 *
 *  @return
 */
+ (NSArray *)revertGuiderListToGroup:(NSArray *)list
{
    NSArray *guiderList = [[list mutableCopy] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        GuiderDistribute *guiderOne = obj1;
        GuiderDistribute *guiderTwo = obj2;
        NSComparisonResult result = guiderOne.rank > guiderTwo.rank;
        return result == NSOrderedDescending;
    }];
    
    NSArray *codeArray = [GuiderDistributeTools continentCodeArray];
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < codeArray.count; i++) {
        
        NSMutableArray * array = [NSMutableArray array];
        [dataSource addObject:array];
    }
    
    for (GuiderDistribute * distrubute in guiderList) {
        int i = 0;
        GuiderDistributeContinent * guilderContinent = distrubute.continents;
        for (NSString *code in codeArray) {
            if ([guilderContinent.code isEqualToString:code]) {
                NSMutableArray *array = dataSource[i];
                [array addObject:distrubute];
                break;
            }
            i++;
        }
    }
    return dataSource;
}

@end
