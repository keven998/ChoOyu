
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
        NSLog(@"*****接收到路线信息********\n%@", json);
        _backUpJson = json;
        _tripId = [json objectForKey:@"id"];
        _tripTitle = [json objectForKey:@"title"];
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
    if (!_backUpTrip) {
        _backUpTrip = [[TripDetail alloc] initWithJson:self.backUpJson];
    }
    return _backUpTrip;
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

                TripPoi *tripPoi = [[_itineraryList objectAtIndex:i] objectAtIndex:j];
                [oneDayToUpdateBackUpTrip safeSetObject:[tripPoi prepareAllDataForUpload] forKey:@"poi"];
                [oneDayDic safeSetObject:[tripPoi prepareSummaryDataForUpdateBackUpTrip] forKey:@"poi"];

                [itineraryListToServer addObject:oneDayDic];
                [itineraryListToUpdateBackUpTrip addObject:oneDayToUpdateBackUpTrip];
            }
        }
        [uploadDicToSave safeSetObject:itineraryListToServer forKey:@"itinerary"];
        [uploadDicToUpdateBackUpTrip safeSetObject:itineraryListToUpdateBackUpTrip forKey:@"itinerary"];

        [uploadDicToSave safeSetObject:[NSNumber numberWithInt:_dayCount] forKey:@"itineraryDays"];
        [uploadDicToUpdateBackUpTrip safeSetObject:[NSNumber numberWithInt:_dayCount] forKey:@"itineraryDays"];

    }
   
    if ([self restaurantListIsChange]) {
        NSLog(@"******保存美食列表**********");

        NSMutableArray *restaurantListToServer = [[NSMutableArray alloc] init];
        NSMutableArray *restaurantListToUpdateBackUpTrip = [[NSMutableArray alloc] init];

        for (TripPoi *tripPoi in _restaurantsList) {
            [restaurantListToUpdateBackUpTrip addObject:[tripPoi prepareAllDataForUpload]];
            [restaurantListToServer addObject:[tripPoi prepareSummaryDataForUpdateBackUpTrip]];
        }
        [uploadDicToSave safeSetObject:restaurantListToServer forKey:@"restaurant"];
        [uploadDicToUpdateBackUpTrip safeSetObject:restaurantListToUpdateBackUpTrip forKey:@"restaurant"];

    }
    
    if ([self shoppingListIsChange]) {
        NSLog(@"******保存购物列表**********");

        NSMutableArray *shoppingListToServer = [[NSMutableArray alloc] init];
        NSMutableArray *shoppingListToUpdateBackUpTrip = [[NSMutableArray alloc] init];

        for (TripPoi *tripPoi in _shoppingList) {
            [shoppingListToUpdateBackUpTrip addObject:[tripPoi prepareAllDataForUpload]];
            [shoppingListToServer addObject:[tripPoi prepareSummaryDataForUpdateBackUpTrip]];
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
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"经过辛辛苦苦的增删改查终于编辑好了,路线内容为：\n%@",str);
    
    [self uploadTripData:uploadDicToSave andUpdateDicToUpdateBackUpTrip:uploadDicToUpdateBackUpTrip completionBlock:completion];
}

- (void)uploadTripData:(NSDictionary *)uploadDic andUpdateDicToUpdateBackUpTrip:(NSDictionary *)updateBackUpTripDic completionBlock:(void(^)(BOOL))completion
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
            [self updateBackupTripJson:updateBackUpTripDic];
            completion(YES);
        } else {
            completion(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
    }];
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
    _backUpTrip = [[TripDetail alloc] initWithJson:self.backUpJson];
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
            _poiType = kSpotPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"restaurant"]) {
            _poiType = kRestaurantPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"shopping"]) {
            _poiType = kShoppingPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"hotel"]) {
            _poiType = kHotelPoi;
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
        if ([json objectForKey:@"rating"] == [NSNull null] || ![json objectForKey:@"rating"]) {
            _rating = 3.5;
        } else {
            _rating = [[json objectForKey:@"rating"] floatValue]*5;
        }
        _telephone = [json objectForKey:@"telephone"];
        if ([json objectForKey:@"location"] != [NSNull null]) {
            _lng = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] firstObject] doubleValue];
            _lat = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] lastObject] doubleValue];
        }

        _locality = [[CityDestinationPoi alloc] initWithJson:[json objectForKey:@"locality"]];

        _timeCost = [json objectForKey:@"timeCostDesc"];
    }
    return self;
}

/**
 * 将所有的字段信息储存为 Dictionary 类型。虽然保存上传的时候只需要上传 id 和 type，但是这里之所以要把所有的字段都集合起来是为了更新“备份路线”
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
        case kSpotPoi:
            poiTypeStr = @"vs";
            break;
            
        case kRestaurantPoi:
            poiTypeStr = @"restaurant";
            break;
        case kShoppingPoi:
            poiTypeStr = @"shopping";
            break;
        case kHotelPoi:
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
    
    NSMutableDictionary *destinationDic = [[NSMutableDictionary alloc] init];
    [destinationDic safeSetObject:_locality.cityId forKey:@"id"];
    [destinationDic safeSetObject:_locality.zhName forKey:@"zhName"];
    [destinationDic safeSetObject:_locality.enName forKey:@"enName"];
    
    [retDic safeSetObject:destinationDic forKey:@"locality"];

    return retDic;
}

/**
 *  保存时候用来上传的 只包含 id 和类型的路线信息
 *
 *  @return
 */
- (NSDictionary *)prepareSummaryDataForUpdateBackUpTrip
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    [retDic safeSetObject:_poiId forKey:@"id"];
    
    NSString *poiTypeStr;
    switch (_poiType) {
        case kSpotPoi:
            poiTypeStr = @"vs";
            break;
            
        case kRestaurantPoi:
            poiTypeStr = @"restaurant";
            break;
        case kShoppingPoi:
            poiTypeStr = @"shopping";
            break;
        case kHotelPoi:
            poiTypeStr = @"hotel";
            break;
            
        default:
            break;
    }
    
    [retDic safeSetObject:poiTypeStr forKey:@"type"];
    return retDic;
}


@end




