
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
    _backUpJson = json;
    _tripId = [json objectForKey:@"id"];
    _tripTitle = [json objectForKey:@"title"];
    _dayCount = [[json objectForKey:@"itineraryDays"] integerValue];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (id destinationsDic in [json objectForKey:@"destinations"]) {
        CityDestinationPoi *poi = [[CityDestinationPoi alloc] initWithJson:destinationsDic];
        [tempArray addObject:poi];
    }
    _destinations = tempArray;
    
    _itineraryList = [self analysisItineraryData:[json objectForKey:@"itinerary"]];
    _restaurantsList = [self analysisRestaurantData:[json objectForKey:@"restaurant"]];
    _shoppingList = [self analysisShoppingData:[json objectForKey:@"shopping"]];
    
    return self;
}

- (TripDetail *)backUpTrip
{
    if (!_backUpTrip) {
        _backUpTrip = [[TripDetail alloc] initWithJson:self.backUpJson];
    }
    return _backUpTrip;
}

- (void)saveTrip:(void (^)(BOOL))completion
{
    
    if (![self restaurantListIsChange] && ![self itineraryListIsChange] && ![self shoppingListIsChange] ) {
        completion(YES);
        return;
    }
    
    NSMutableDictionary *uploadDic = [[NSMutableDictionary alloc] init];
    
    if ([self itineraryListIsChange]) {
        NSLog(@"******保存路线列表**********");
        NSMutableArray *itineraryListToServer = [[NSMutableArray alloc] init];
        for (int i = 0; i < _itineraryList.count; i++) {
            for (int j = 0; j < [[_itineraryList objectAtIndex:i] count]; j++) {
                NSMutableDictionary *oneDayDic = [[NSMutableDictionary alloc] init];
                [oneDayDic setObject:[NSNumber numberWithInt:i] forKeyedSubscript:@"dayIndex"];
                TripPoi *tripPoi = [[_itineraryList objectAtIndex:i] objectAtIndex:j];
                [oneDayDic safeSetObject:[tripPoi prepareAllDataForUpload] forKey:@"poi"];
                [itineraryListToServer addObject:oneDayDic];
            }
        }
        [uploadDic safeSetObject:itineraryListToServer forKey:@"itinerary"];
        [uploadDic safeSetObject:[NSNumber numberWithInt:_dayCount] forKey:@"itineraryDays"];
    }
   
    if ([self restaurantListIsChange]) {
        NSLog(@"******保存美食列表**********");

        NSMutableArray *restaurantListToServer = [[NSMutableArray alloc] init];
        for (TripPoi *tripPoi in _restaurantsList) {
            [restaurantListToServer addObject:[tripPoi prepareAllDataForUpload]];
        }
        [uploadDic safeSetObject:restaurantListToServer forKey:@"restaurant"];
    }
    
    if ([self shoppingListIsChange]) {
        NSLog(@"******保存购物列表**********");

        NSMutableArray *shoppingListToServer = [[NSMutableArray alloc] init];
        for (TripPoi *tripPoi in _shoppingList) {
            [shoppingListToServer addObject:[tripPoi prepareAllDataForUpload]];
        }
        [uploadDic safeSetObject:shoppingListToServer forKey:@"shopping"];
    }
    
    [uploadDic safeSetObject:_tripId forKey:@"id"];
    [uploadDic safeSetObject:_tripTitle forKey:@"title"];
    
    NSMutableArray *destinationsArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _destinations) {
        NSMutableDictionary *poiDic = [[NSMutableDictionary alloc] init];
        [poiDic safeSetObject:poi.cityId forKey:@"id"];
        [poiDic safeSetObject:poi.zhName forKey:@"zhName"];
        [poiDic safeSetObject:poi.enName forKey:@"enName"];
        [destinationsArray addObject:poiDic];
    }
    
    [uploadDic safeSetObject:destinationsArray forKey:@"destinations"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:uploadDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"经过辛辛苦苦的增删改查终于编辑好了,路线内容为：\n%@",str);
    
    [self uploadTripData:(NSDictionary *)uploadDic completionBlock:completion];
}

- (void)uploadTripData:(NSDictionary *)uploadDic completionBlock:(void(^)(BOOL))completion
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [SVProgressHUD show];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    [manager POST:API_SAVE_TRIP parameters:uploadDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self updateBackupTripJson:uploadDic];
            completion(YES);
        } else {
            completion(NO);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
    }];

}

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
        [currentDayArray addObject:[[TripPoi alloc] initWithJson:[oneDayDic objectForKey:@"poi"]]];
    }
    return retArray;
}

- (NSMutableArray *)analysisRestaurantData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (id oneDayDic in json) {
        [retArray addObject:[[TripPoi alloc] initWithJson:oneDayDic]];
    }
    return retArray;

}

- (NSMutableArray *)analysisShoppingData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (id oneDayDic in json) {
        [retArray addObject:[[TripPoi alloc] initWithJson:oneDayDic]];
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
            TripPoi *poi = [[self.itineraryList objectAtIndex:i] objectAtIndex:j];
            TripPoi *backUpPoi = [[self.backUpTrip.itineraryList objectAtIndex:i] objectAtIndex:j];
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
        TripPoi *poi = [self.restaurantsList objectAtIndex:i];
        TripPoi *backUpPoi = [self.backUpTrip.restaurantsList objectAtIndex:i];
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
        TripPoi *poi = [self.shoppingList objectAtIndex:i];
        TripPoi *backUpPoi = [self.backUpTrip.shoppingList objectAtIndex:i];
        if (![poi.poiId isEqualToString:backUpPoi.poiId]) {
            return YES;
        }
    }
    
    return NO;
}

@end


@implementation TripPoi

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _poiId = [json objectForKey:@"id"];
        if ([[json objectForKey:@"type"] isEqualToString:@"vs"]) {
            _poiType = TripSpotPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"restaurant"]) {
            _poiType = TripRestaurantPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"shopping"]) {
            _poiType = TripShoppingPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"hotel"]) {
            _poiType = TripHotelPoi;
        }
        
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _desc = [json objectForKey:@"desc"];
        _priceDesc = [json objectForKey:@"priceDesc"];
        _address = [json objectForKey:@"address"];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [tempArray addObject:image];
        }
        _images = tempArray;
        _rating = [[json objectForKey:@"rating"] floatValue];
        _telephone = [json objectForKey:@"telephone"];
        _lng = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] firstObject] doubleValue];
        _lat = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] lastObject] doubleValue];
        NSMutableArray *tempLocArray = [[NSMutableArray alloc] init];
        for (id destinationDic in [json objectForKey:@"locList"]) {
            CityDestinationPoi *poi = [[CityDestinationPoi alloc] initWithJson:destinationDic];
            [tempLocArray addObject:poi];
        }
        _locList = tempLocArray;
        _timeCost = [json objectForKey:@"timeCostDesc"];
    }
    return self;
}

/**
 *
 *
 *  @return 
 */
- (NSDictionary *)prepareAllDataForUpload
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    [retDic safeSetObject:_poiId forKey:@"id"];
    [retDic safeSetObject:_zhName forKey:@"zhName"];
    [retDic safeSetObject:_enName forKey:@"enName"];
    [retDic safeSetObject:_desc forKey:@"desc"];
    [retDic safeSetObject:_priceDesc forKey:@"priceDesc"];
    [retDic safeSetObject:_address forKey:@"address"];
    [retDic safeSetObject:[NSNumber numberWithFloat:_rating] forKey:@"rating"];
    [retDic safeSetObject:_telephone forKey:@"telephone"];
    [retDic safeSetObject:_timeCost forKey:@"timeCostDesc"];
    
    NSString *poiTypeStr;
    switch (_poiType) {
        case TripSpotPoi:
            poiTypeStr = @"vs";
            break;
            
        case TripRestaurantPoi:
            poiTypeStr = @"restaurant";
            break;
        case TripShoppingPoi:
            poiTypeStr = @"shopping";
            break;
        case TripHotelPoi:
            poiTypeStr = @"hotel";
            break;
            
        default:
            break;
    }
    
    [retDic safeSetObject:poiTypeStr forKey:@"type"];
    
    NSMutableArray *coordinatesArray = [[NSMutableArray alloc] init];
    [coordinatesArray addObject:[NSNumber numberWithDouble:_lng]];
    [coordinatesArray addObject:[NSNumber numberWithDouble:_lat]];
    [retDic safeSetObject:@{@"coordinates":coordinatesArray} forKey:@"location"];
    
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (TaoziImage *image in _images) {
        NSMutableDictionary *imageDic = [[NSMutableDictionary alloc] init];
        [imageDic safeSetObject:image.imageUrl forKey:@"url"];
        [imageArray addObject:imageDic];
    }
    
    [retDic safeSetObject:imageArray forKey:@"images"];
    
    NSMutableArray *localListArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _locList) {
        NSMutableDictionary *destinationDic = [[NSMutableDictionary alloc] init];
        [destinationDic safeSetObject:poi.cityId forKey:@"id"];
        [destinationDic safeSetObject:poi.zhName forKey:@"zhName"];
        [destinationDic safeSetObject:poi.enName forKey:@"enName"];
        [localListArray addObject:destinationDic];
    }
    
    [retDic safeSetObject:localListArray forKey:@"locList"];

    return retDic;
}

@end




