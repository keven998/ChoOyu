//  Destinations.m
//  PeachTravelDemo
//
//  Created by liangpengshuai on 14/9/23.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//
/*
 *保存目的地界面所有目的地数据
 */

#import "Destinations.h"
#import "CityDestinationPoi.h"
#import "CountryDestination.h"

@implementation Destinations

- (void)initDomesticCitiesWithJson:(id)json
{
    if (!_domesticCities) {
        _domesticCities = [[NSMutableArray alloc] init];
    }
    
    /*
    for (id cityDic in json) {
        CityDestinationPoi *cityPoi = [[CityDestinationPoi alloc] initWithJson:cityDic];
        [_domesticCities addObject:cityPoi];
    }
     */
    
    CityDestinationPoi *city = [[CityDestinationPoi alloc] initWithJson:@{@"id":@"1",
                                                                          @"zhName":@"北京"
                                                                          }];
    CityDestinationPoi *city1 = [[CityDestinationPoi alloc] initWithJson:@{@"id":@"2",
                                                                          @"zhName":@"和浩特"
                                                                          }];
    CityDestinationPoi *city2 = [[CityDestinationPoi alloc] initWithJson:@{@"id":@"3",
                                                                          @"zhName":@"上海"
                                                                          }];
    CityDestinationPoi *city3 = [[CityDestinationPoi alloc] initWithJson:@{@"id":@"4",
                                                                          @"zhName":@"北海"
                                                                          }];
    CityDestinationPoi *city4 = [[CityDestinationPoi alloc] initWithJson:@{@"id":@"5",
                                                                          @"zhName":@"拉西亚群岛"
                                                                          }];
    CityDestinationPoi *city5 = [[CityDestinationPoi alloc] initWithJson:@{@"id":@"6",
                                                                          @"zhName":@"北京"
                                                                          }];
    CityDestinationPoi *city6 = [[CityDestinationPoi alloc] initWithJson:@{@"id":@"7",
                                                                           @"zhName":@"呼和浩特"
                                                                           }];
    CityDestinationPoi *city7 = [[CityDestinationPoi alloc] initWithJson:@{@"id":@"8",
                                                                           @"zhName":@"海阳"
                                                                           }];
    CityDestinationPoi *city8 = [[CityDestinationPoi alloc] initWithJson:@{@"id":@"9",
                                                                           @"zhName":@"北海"
                                                                           }];
    CityDestinationPoi *city9 = [[CityDestinationPoi alloc] initWithJson:@{@"id":@"10",
                                                                           @"zhName":@"马拉西亚群岛"}];
    
    [_domesticCities addObjectsFromArray:@[city,city1,city2,city3,city4,city5,city6,city7,city8,city9]];
}

- (void)initForeignCountriesWithJson:(id)json
{
    if (!_foreignCountries) {
        _foreignCountries = [[NSMutableArray alloc] init];
    }
    /*
    for (id CountryDic in json) {
        CountryDestination *country = [[CountryDestination alloc] initWithJson:CountryDic];
        [_foreignCountries addObject:country];
    }
     */
    
    CountryDestination *dest = [[CountryDestination alloc] init];
    dest.zhName = @"韩国";
    dest.desc = @"水电费克里斯蒂就离开放暑假了卡机弗兰卡积分卡拉丝机付了款解放东路可视对讲法律文件佛 i 问 u 分哦骗我 i 分配 i 的；是；‘’撒就赶快拉德斯基嘎斯龙卷风破网 i 我；二姐夫稳婆克里斯蒂就离开说的话 v 撒旦咖啡店就是哇解放克里斯多夫建安看来是；减肥 i 哦啊 u 蜂窝 iu 惹我 i 解放啦三角阀；十几分了；撒开房间啊是水电费静安寺零度空间发卡量三角阀螺丝粉 啦";
    CityDestinationPoi *poi = [[CityDestinationPoi alloc] init];
    poi.zhName = @"大阪";
    poi.cityId = @"1";
    CityDestinationPoi *poi2 = [[CityDestinationPoi alloc] init];
    poi2.zhName = @"大阪哈哈哈";
    poi2.cityId = @"2";
    CityDestinationPoi *poi3 = [[CityDestinationPoi alloc] init];
    poi3.zhName = @"大阪的";
    poi3.cityId = @"3";
    dest.cities = @[poi,poi2, poi3];
    [_foreignCountries addObject:dest];
    
    CountryDestination *dest1 = [[CountryDestination alloc] init];
    dest1.zhName = @"韩国";
    dest1.desc = @"水电费克里斯蒂就离开放暑假了卡机弗兰卡积分卡拉丝机付了款解放东路可视对讲法律文件佛 i 问 u 分哦骗我 i 分配 i 的；是；‘’撒就赶快拉德斯基嘎斯龙卷风破网 i 我；二姐夫稳婆克里斯蒂就离开说的话 v 撒旦咖啡店就是哇解放克里斯多夫建安看来是；减肥 i 哦啊 u 蜂窝 iu 惹我 i 解放啦三角阀；十几分了；撒开房间啊是水电费静安寺零度空间发卡量三角阀螺丝粉 啦";
    CityDestinationPoi *spoi = [[CityDestinationPoi alloc] init];
    spoi.zhName = @"大阪";
    spoi.cityId= @"4";
    CityDestinationPoi *spoi2 = [[CityDestinationPoi alloc] init];
    spoi2.zhName = @"大阪斯蒂芬森";
    spoi2.cityId = @"5";
    CityDestinationPoi *spoi3 = [[CityDestinationPoi alloc] init];
    spoi3.zhName = @"大阪搜索";
    
    CityDestinationPoi *spoi4 = [[CityDestinationPoi alloc] init];
    spoi4.zhName = @"大阪";
    spoi4.cityId = @"6";
    CityDestinationPoi *spoi5 = [[CityDestinationPoi alloc] init];
    spoi5.zhName = @"大阪斯蒂芬森";
    spoi5.cityId = @"7";
    CityDestinationPoi *spoi6 = [[CityDestinationPoi alloc] init];
    spoi6.zhName = @"大阪搜索";
    spoi6.cityId = @"8";
    
    dest1.cities = @[spoi,spoi2, spoi3, spoi4, spoi5, spoi6];
    
    CountryDestination *dest2 = [[CountryDestination alloc] init];
    dest2.zhName = @"韩国";
    dest2.desc = @"水电费克里斯蒂就离开放暑假了卡机弗兰卡积";
    CityDestinationPoi *qpoi = [[CityDestinationPoi alloc] init];
    qpoi.zhName = @"大阪";
    qpoi.cityId = @"10";
    CityDestinationPoi *qpoi2 = [[CityDestinationPoi alloc] init];
    qpoi2.zhName = @"大阪";
    qpoi2.cityId = @"11";
    CityDestinationPoi *qpoi3 = [[CityDestinationPoi alloc] init];
    qpoi3.zhName = @"大阪";
    qpoi3.cityId = @"12";
    dest2.cities = @[qpoi,qpoi2, qpoi3];
    CountryDestination *dest3 = [[CountryDestination alloc] init];
    dest3.zhName = @"韩国";
    dest3.desc = @"水电费克里斯蒂就离开放暑假了卡机弗兰卡积分卡拉丝机付了款解放东路可视对讲法律文件佛 i 问 u 分哦骗我 i 分配 i 的；是；";
    [_foreignCountries addObject:dest1];
    [_foreignCountries addObject:dest2];
    [_foreignCountries addObject:dest3];

}

- (NSMutableArray *)destinationsSelected
{
    if (!_destinationsSelected) {
        _destinationsSelected = [[NSMutableArray alloc] init];
    }
    return _destinationsSelected;
}

- (NSDictionary *)destinationsGroupByPin
{
    NSMutableArray *chineseStringsArray = [[NSMutableArray alloc] init];
    for (id tempCity in self.domesticCities) {
        [chineseStringsArray addObject:tempCity];
    }
    NSMutableArray *sectionHeadsKeys = [[NSMutableArray alloc] init];
    //sort the ChineseStringArr by pinYin
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    NSMutableArray *arrayForArrays = [NSMutableArray array];
    BOOL checkValueAtIndex= NO;  //flag to check
    NSMutableArray *TempArrForGrouping = nil;
    
    for(int index = 0; index < [chineseStringsArray count]; index++)
    {
        CityDestinationPoi *city = (CityDestinationPoi *)[chineseStringsArray objectAtIndex:index];
        NSMutableString *strchar= [NSMutableString stringWithString:city.pinyin];
        NSString *sr= [strchar substringToIndex:1];
        if(![sectionHeadsKeys containsObject:[sr uppercaseString]])//here I'm checking whether the character already in the selection header keys or not
        {
            [sectionHeadsKeys addObject:[sr uppercaseString]];
            TempArrForGrouping = [[NSMutableArray alloc] initWithObjects:nil];
            checkValueAtIndex = NO;
        }
        if([sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [TempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
            if(checkValueAtIndex == NO)
            {
                [arrayForArrays addObject:TempArrForGrouping];
                checkValueAtIndex = YES;
            }
        }
    }
    return @{@"headerKeys":sectionHeadsKeys, @"content":arrayForArrays};
}

@end