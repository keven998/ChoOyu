//
//  PoiManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/28/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "PoiManager.h"

@implementation PoiManager

+ (void)asyncLoadDomescticRecommendPoiWithCompletionBlcok:(void (^)(BOOL isSuccess, NSArray *poiList))completion
{
    [self asyncLoadRecommendPoiWithIsAbroad:NO completionBlcok:^(BOOL isSuccess, NSArray *poiList) {
        completion(isSuccess, poiList);
    }];
    
}

+ (void)asyncLoadForeignRecommendPoiWithCompletionBlcok:(void (^)(BOOL isSuccess, NSArray *poiList))completion
{
    [self asyncLoadRecommendPoiWithIsAbroad:YES completionBlcok:^(BOOL isSuccess, NSArray *poiList) {
        completion(isSuccess, poiList);
    }];
}

+ (void)asyncLoadRecommendPoiWithIsAbroad:(BOOL)isAbroad completionBlcok:(void (^)(BOOL, NSArray *))completion
{
    NSNumber *imageWidth = [NSNumber numberWithInt:450];
    NSDictionary *params = @{@"imgWidth": imageWidth, @"itemType": @"locality", @"abroad": [NSNumber numberWithBool:isAbroad]};
    
    NSString *url = [NSString stringWithFormat:@"%@recommendations", API_GET_LOCALITIES];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                PoiRecommend *poi = [[PoiRecommend alloc] initWithJson:dic];
                [retArray addObject:poi];
            }
            completion(YES, retArray);
            
        } else {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
            completion(NO, nil);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showHint:HTTP_FAILED_HINT];
        completion(NO, nil);
        
    }];
}

+ (void)asyncLoadRecommendCountriesWithContinentCode:(kContinentCode)continentCode completionBlcok:(void (^)(BOOL, NSArray *))completion
{
    NSString *continentCodeStr;
    switch (continentCode) {
        case kRECOM:
            continentCodeStr = @"RCOM";
            break;
            
        case kEU:
            continentCodeStr = @"EU";
            break;
            
        case kAS:
            continentCodeStr = @"AS";
            break;
            
        case kAF:
            continentCodeStr = @"AF";
            break;
            
        case kNA:
            continentCodeStr = @"NA";
            break;
            
        case kSA:
            continentCodeStr = @"SA";
            break;
            
        case kOC:
            continentCodeStr = @"OC";
            break;
            
        default:
            break;
    }
    NSDictionary *params = @{@"continentCode": continentCodeStr};
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking GET:API_GET_COUNTRIES parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                CountryModel *poi = [[CountryModel alloc] initWithJson:dic];
                [retArray addObject:poi];
            }
            completion(YES, retArray);
            
        } else {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
            completion(NO, nil);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showHint:HTTP_FAILED_HINT];
        completion(NO, nil);
        
    }];
}

+ (void)asyncLoadCitiesOfCountry:(NSString *)countryId completionBlcok:(void (^)(BOOL isSuccess, NSArray *poiList))completion
{
    NSDictionary *params = @{@"countryId": countryId};
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking GET:API_GET_CITIES parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                CityPoi *poi = [[CityPoi alloc] initWithJson:dic];
                [retArray addObject:poi];
            }
            completion(YES, retArray);
            
        } else {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
            completion(NO, nil);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showHint:HTTP_FAILED_HINT];
        completion(NO, nil);
        
    }];
}

+ (void)asyncLoadCityInfo:(NSString *)cityId completionBlock:(void (^)(BOOL, CityPoi *))completion
{
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@", API_GET_CITYDETAIL, cityId];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:kWindowWidth*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    //获取城市信息
    [LXPNetworking GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"加载城市详情%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            CityPoi *poi = [[CityPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            completion(YES, poi);
           
        } else {
            completion(NO, nil);
           
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);

    }];
}


+ (void)searchPoiWithKeyword:(NSString *)keyWord andSearchCount:(NSInteger)count andPoiType:(TZPoiType)poiType completionBlock:(void (^)(BOOL isSuccess, NSArray *searchResultList))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:270];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:keyWord forKey:@"keyword"];
    
    BOOL searchSpot = (poiType == kSpotPoi || poiType == 0);
    BOOL searchRestaurant = (poiType == kRestaurantPoi || poiType == 0);
    BOOL searchShopping = (poiType == kShoppingPoi || poiType == 0);
    BOOL searchCity = (poiType == kCityPoi || poiType == 0);
    BOOL searchHotel = (poiType == kHotelPoi || poiType == 0);
    
    [params setObject:[NSNumber numberWithBool:searchCity] forKey:@"loc"];
    [params setObject:[NSNumber numberWithBool:searchSpot] forKey:@"vs"];
    [params setObject:[NSNumber numberWithBool:searchRestaurant] forKey:@"restaurant"];
    [params setObject:[NSNumber numberWithBool:searchHotel] forKey:@"hotel"];
    [params setObject:[NSNumber numberWithBool:searchShopping] forKey:@"shopping"];
    [params setObject:[NSNumber numberWithInteger:count] forKey:@"pageSize"];
    
    [LXPNetworking GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSArray *retArray = [self analysisSearchResultData:[responseObject objectForKey:@"result"]];
            completion(YES, retArray);
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];
}

+ (NSArray *)analysisSearchResultData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *cityDic = [[NSMutableDictionary alloc] init];
    [cityDic setObject:@"城市" forKey:@"typeDesc"];
    NSMutableArray *cities = [[NSMutableArray alloc] init];
    
    for (id dic in [json objectForKey:@"locality"]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:kCityPoi andJson:dic];
        poi.poiType = kCityPoi;
        [cities addObject:poi];
    }
    if (cities.count > 0) {
        [cityDic setObject:cities forKey:@"content"];
        [retArray addObject:cityDic];
        [cityDic setObject:[NSNumber numberWithInt:kCityPoi] forKey:@"type"];
    }
    NSMutableDictionary *spotDic = [[NSMutableDictionary alloc] init];
    
    [spotDic setObject:@"景点" forKey:@"typeDesc"];
    NSMutableArray *spots = [[NSMutableArray alloc] init];
    for (id dic in [json objectForKey:@"vs"]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:kSpotPoi andJson:dic];
        [spots addObject:poi];
    }
    if (spots.count > 0) {
        [spotDic setObject:spots forKey:@"content"];
        [spotDic setObject:[NSNumber numberWithInt:kSpotPoi] forKey:@"type"];
        
        [retArray addObject:spotDic];
    }
    
    NSMutableDictionary *restaurantDic = [[NSMutableDictionary alloc] init];
    
    [restaurantDic setObject:@"美食" forKey:@"typeDesc"];
    NSMutableArray *restaurants = [[NSMutableArray alloc] init];
    for (id dic in [json objectForKey:@"restaurant"]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:kRestaurantPoi andJson:dic];
        [restaurants addObject:poi];
    }
    if (restaurants.count > 0) {
        [restaurantDic setObject:restaurants forKey:@"content"];
        [restaurantDic setObject:[NSNumber numberWithInt:kRestaurantPoi] forKey:@"type"];
        [retArray addObject:restaurantDic];
    }
    
    NSMutableDictionary *shoppingDic = [[NSMutableDictionary alloc] init];
    
    [shoppingDic setObject:@"购物" forKey:@"typeDesc"];
    NSMutableArray *shoppingArray = [[NSMutableArray alloc] init];
    for (id dic in [json objectForKey:@"shopping"]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:kShoppingPoi andJson:dic];
        [shoppingArray addObject:poi];
    }
    if (shoppingArray.count > 0) {
        [shoppingDic setObject:shoppingArray forKey:@"content"];
        [shoppingDic setObject:[NSNumber numberWithInt:kShoppingPoi] forKey:@"type"];
        
        [retArray addObject:shoppingDic];
    }
    
    NSMutableDictionary *hotelDic = [[NSMutableDictionary alloc] init];
    
    [hotelDic setObject:@"酒店" forKey:@"typeDesc"];
    NSMutableArray *hotels = [[NSMutableArray alloc] init];
    for (id dic in [json objectForKey:@"hotel"]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:kHotelPoi andJson:dic];
        [hotels addObject:poi];
    }
    if (hotels.count > 0) {
        [hotelDic setObject:hotels forKey:@"content"];
        [hotelDic setObject:[NSNumber numberWithInt:kHotelPoi] forKey:@"type"];
        
        [retArray addObject:hotelDic];
    }
    return retArray;
}

+ (void)asyncGetDescriptionOfSearchText:(NSString *)searchText andPoiType:(TZPoiType)poiType completionBlock:(void (^)(BOOL, NSDictionary *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:270];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:searchText forKeyedSubscript:@"query"];
    
    if (poiType == kShoppingPoi) {
        [params setObject:@"shopping" forKey:@"scope"];
        
    } else if (poiType == kRestaurantPoi) {
        [params setObject:@"restaurant" forKeyedSubscript:@"scope"];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/ancillary-info", API_SEARCH];
    
    [LXPNetworking GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic safeSetObject:[[responseObject objectForKey:@"result"] objectForKey:@"desc"] forKey:@"desc"];
            [dic safeSetObject:[[responseObject objectForKey:@"result"] objectForKey:@"detailUrl"] forKey:@"detailUrl"];
            completion(YES, dic);
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];
    
}

@end
