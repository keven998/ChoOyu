
//
//  TripDetail.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripDetail.h"
#import "CityDestinationPoi.h"
#import "AccountManager.h"

@implementation TripDetail

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
//        NSLog(@"*****接收到路线信息********\n%@", json);
        _backUpJson = json;
        _tripId = [json objectForKey:@"id"];
        _tripTitle = [json objectForKey:@"title"];
        _tripDetailUrl = [json objectForKey:@"detailUrl"];
        _dayCount = [[json objectForKey:@"itineraryDays"] integerValue];
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            [imageArray addObject:[[TaoziImage alloc] initWithJson:imageDic]];
        }
        _images = imageArray;
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id destinationsDic in [json objectForKey:@"localities"]) {
            CityDestinationPoi *poi = [[CityDestinationPoi alloc] initWithJson:destinationsDic];
            [tempArray addObject:poi];
        }
        _destinations = tempArray;
        
        _itineraryList = [self analysisItineraryData:[json objectForKey:@"itinerary"]];
        _restaurantsList = [self analysisRestaurantData:[json objectForKey:@"restaurant"]];
        _shoppingList = [self analysisShoppingData:[json objectForKey:@"shopping"]];
    }
    return self;
}

- (TripDetail *)backUpTrip
{
    return [[TripDetail alloc] initWithJson:self.backUpJson];
}


- (BOOL)tripIsChange
{
    return !(![self restaurantListIsChange] && ![self itineraryListIsChange] && ![self shoppingListIsChange]);
}

- (void)saveTrip:(void (^)(BOOL))completion
{
    if (![self restaurantListIsChange] && ![self itineraryListIsChange] && ![self shoppingListIsChange] ) {
        completion(YES);
        return;
    }
    
    //保存时候用来上传的 dic， 只储存 id 和 type
    NSMutableDictionary *uploadDicToSave = [[NSMutableDictionary alloc] init];
    //保存成功后用来更新备份路线的 dic，储存所有字段的内容
    NSMutableDictionary *uploadDicToUpdateBackUpTrip = [[NSMutableDictionary alloc] init];

    if ([self itineraryListIsChange]) {
        NSLog(@"******保存路线列表**********");
        //保存时候用来上传的 dic， 只储存 id 和 type
        NSMutableArray *itineraryListToServer = [[NSMutableArray alloc] init];
        //保存成功后用来更新备份路线的 dic，储存所有字段的内容
        NSMutableArray *itineraryListToUpdateBackUpTrip = [[NSMutableArray alloc] init];

        for (int i = 0; i < _itineraryList.count; i++) {
            for (int j = 0; j < [[_itineraryList objectAtIndex:i] count]; j++) {
                NSMutableDictionary *oneDayDic = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *oneDayToUpdateBackUpTrip = [[NSMutableDictionary alloc] init];
                [oneDayDic setObject:[NSNumber numberWithInt:i] forKeyedSubscript:@"dayIndex"];
                [oneDayToUpdateBackUpTrip setObject:[NSNumber numberWithInt:i] forKeyedSubscript:@"dayIndex"];

                SuperPoi *tripPoi = [[_itineraryList objectAtIndex:i] objectAtIndex:j];
                [oneDayToUpdateBackUpTrip safeSetObject:[tripPoi enCodeAllDataToDictionary] forKey:@"poi"];
                [oneDayDic safeSetObject:[tripPoi enCodeSummaryDataToDictionary] forKey:@"poi"];

                [itineraryListToServer addObject:oneDayDic];
                [itineraryListToUpdateBackUpTrip addObject:oneDayToUpdateBackUpTrip];
            }
        }
        [uploadDicToSave safeSetObject:itineraryListToServer forKey:@"itinerary"];
        [uploadDicToUpdateBackUpTrip safeSetObject:itineraryListToUpdateBackUpTrip forKey:@"itinerary"];
        _dayCount = _itineraryList.count;
        [uploadDicToSave safeSetObject:[NSNumber numberWithInteger:_dayCount] forKey:@"itineraryDays"];
        [uploadDicToUpdateBackUpTrip safeSetObject:[NSNumber numberWithInteger:_dayCount] forKey:@"itineraryDays"];

    }
   
    if ([self restaurantListIsChange]) {
        NSLog(@"******保存美食列表**********");

        NSMutableArray *restaurantListToServer = [[NSMutableArray alloc] init];
        NSMutableArray *restaurantListToUpdateBackUpTrip = [[NSMutableArray alloc] init];

        for (SuperPoi *tripPoi in _restaurantsList) {
            [restaurantListToUpdateBackUpTrip addObject:[tripPoi enCodeAllDataToDictionary]];
            [restaurantListToServer addObject:[tripPoi enCodeSummaryDataToDictionary]];
        }
        [uploadDicToSave safeSetObject:restaurantListToServer forKey:@"restaurant"];
        [uploadDicToUpdateBackUpTrip safeSetObject:restaurantListToUpdateBackUpTrip forKey:@"restaurant"];

    }
    
    if ([self shoppingListIsChange]) {
        NSLog(@"******保存购物列表**********");

        NSMutableArray *shoppingListToServer = [[NSMutableArray alloc] init];
        NSMutableArray *shoppingListToUpdateBackUpTrip = [[NSMutableArray alloc] init];

        for (SuperPoi *tripPoi in _shoppingList) {
            [shoppingListToUpdateBackUpTrip addObject:[tripPoi enCodeAllDataToDictionary]];
            [shoppingListToServer addObject:[tripPoi enCodeSummaryDataToDictionary]];
        }
        [uploadDicToSave safeSetObject:shoppingListToServer forKey:@"shopping"];
        [uploadDicToUpdateBackUpTrip safeSetObject:shoppingListToUpdateBackUpTrip forKey:@"shopping"];

    }
    
    [uploadDicToSave safeSetObject:_tripId forKey:@"id"];
    [uploadDicToSave safeSetObject:_tripTitle forKey:@"title"];
    
    NSMutableArray *destinationsArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _destinations) {
        NSMutableDictionary *poiDic = [[NSMutableDictionary alloc] init];
        [poiDic safeSetObject:poi.cityId forKey:@"id"];
        [poiDic safeSetObject:poi.zhName forKey:@"zhName"];
        [poiDic safeSetObject:poi.enName forKey:@"enName"];
        [destinationsArray addObject:poiDic];
    }
    
    [uploadDicToSave safeSetObject:destinationsArray forKey:@"localities"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:uploadDicToSave options:NSJSONWritingPrettyPrinted error:nil];

    NSLog(@"经过辛辛苦苦的增删改查终于编辑好了,路线内容为：\n%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    [self uploadTripData:uploadDicToSave andUpdateDicToUpdateBackUpTrip:uploadDicToUpdateBackUpTrip completionBlock:completion];
}

- (void)uploadTripData:(NSDictionary *)uploadDic andUpdateDicToUpdateBackUpTrip:(NSDictionary *)updateBackUpTripDic completionBlock:(void(^)(BOOL))completion
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    [manager POST:API_SAVE_TRIP parameters:uploadDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self updateBackupTripJson:updateBackUpTripDic];
            completion(YES);
        } else {
            completion(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
    }];
}

- (void)updateTripDestinations:(void (^)(BOOL))completion withDestinations:(NSArray *)destinations
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableArray *destinationsArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in destinations) {
        NSMutableDictionary *poiDic = [[NSMutableDictionary alloc] init];
        [poiDic safeSetObject:poi.cityId forKey:@"id"];
        [poiDic safeSetObject:poi.zhName forKey:@"zhName"];
        [poiDic safeSetObject:poi.enName forKey:@"enName"];
        [destinationsArray addObject:poiDic];
    }
    
    NSMutableDictionary *uploadDic = [[NSMutableDictionary alloc] init];
    [uploadDic safeSetObject:_tripId forKey:@"id"];
    [uploadDic safeSetObject:destinationsArray forKey:@"localities"];
    
    [manager POST:API_SAVE_TRIP parameters:uploadDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _destinations = destinations;
            [self updateBackupTripDestinationJson:destinationsArray];
            completion(YES);
        } else {
            completion(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
    }];
}

/**
 *  保存攻略的目的地列表成功后更新备份路线
 *
 *  @param uploadDic
 */
- (void)updateBackupTripDestinationJson:(NSMutableArray *)destinations
{
    NSMutableDictionary *tempDic = [_backUpJson mutableCopy];
    [tempDic setObject:destinations forKey:@"localities"];
    _backUpJson = tempDic;
}

/**
 *  当保存成功后将备份的路线更新
 *
 *  @param uploadDic 最新的路线
 */
- (void)updateBackupTripJson:(NSDictionary *)uploadDic
{
    NSMutableDictionary *tempDic = [_backUpJson mutableCopy];
    if ([uploadDic objectForKey:@"itinerary"]) {
        [tempDic setObject:[uploadDic objectForKey:@"itinerary"] forKey:@"itinerary"];
        [tempDic setObject:[uploadDic objectForKey:@"itineraryDays"] forKey:@"itineraryDays"];
    }
    if ([uploadDic objectForKey:@"restaurant"]) {
        [tempDic setObject:[uploadDic objectForKey:@"restaurant"] forKey:@"restaurant"];
    }
    if ([uploadDic objectForKey:@"shopping"]) {
        [tempDic setObject:[uploadDic objectForKey:@"shopping"] forKey:@"shopping"];
    }
    _backUpJson = tempDic;
}

- (NSMutableArray *)analysisItineraryData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _dayCount; i++) {
        NSMutableArray *oneDayArray = [[NSMutableArray alloc] init];
        [retArray addObject:oneDayArray];
    }
    for (id oneDayDic in json) {
        NSMutableArray *currentDayArray = [retArray objectAtIndex:[[oneDayDic objectForKey:@"dayIndex"] integerValue]];
        [currentDayArray addObject:[PoiFactory poiWithJson:[oneDayDic objectForKey:@"poi"]]];
    }
    return retArray;
}

- (NSMutableArray *)analysisRestaurantData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (id oneDayDic in json) {
        [retArray addObject:[PoiFactory poiWithJson: oneDayDic]];
    }
    return retArray;

}

- (NSMutableArray *)analysisShoppingData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (id oneDayDic in json) {
        [retArray addObject:[PoiFactory poiWithJson:oneDayDic]];
    }
    return retArray;
}

//线路列表是否发生了变化
- (BOOL)itineraryListIsChange
{
    //天数发生变化
    if (self.itineraryList.count != self.backUpTrip.itineraryList.count) {
        return YES;
    }
    //每天的 poi 数目发生变化
    for (int i = 0; i < self.itineraryList.count; i++) {
        NSArray *oneDayArry = [self.itineraryList objectAtIndex:i];
        NSArray *backUpOneDayArray = [self.backUpTrip.itineraryList objectAtIndex:i];
        if (oneDayArry.count != backUpOneDayArray.count) {
            return YES;
        }
    }
    
    //poi 的顺序发生变化
    for (int i = 0; i<self.itineraryList.count; i++) {
        for (int j = 0; j<[[self.itineraryList objectAtIndex:i] count]; j++) {
            SuperPoi *poi = [[self.itineraryList objectAtIndex:i] objectAtIndex:j];
            SuperPoi *backUpPoi = [[self.backUpTrip.itineraryList objectAtIndex:i] objectAtIndex:j];
            if (![poi.poiId isEqualToString:backUpPoi.poiId]) {
                return YES;
            }
        }
    }

    return NO;
}

//美食列表是否发生了变化
- (BOOL)restaurantListIsChange
{
    if (self.restaurantsList.count != self.backUpTrip.restaurantsList.count) {
        return YES;
    }
    
    for (int i = 0; i<self.restaurantsList.count; i++) {
        SuperPoi *poi = [self.restaurantsList objectAtIndex:i];
        SuperPoi *backUpPoi = [self.backUpTrip.restaurantsList objectAtIndex:i];
        if (![poi.poiId isEqualToString:backUpPoi.poiId]) {
            return YES;
        }
    }
    
    return NO;
}

//购物列表是否发生了变化
- (BOOL)shoppingListIsChange
{
    if (self.shoppingList.count != self.backUpTrip.shoppingList.count) {
        return YES;
    }
    
    for (int i = 0; i<self.shoppingList.count; i++) {
        SuperPoi *poi = [self.shoppingList objectAtIndex:i];
        SuperPoi *backUpPoi = [self.backUpTrip.shoppingList objectAtIndex:i];
        if (![poi.poiId isEqualToString:backUpPoi.poiId]) {
            return YES;
        }
    }
    
    return NO;
}

@end






