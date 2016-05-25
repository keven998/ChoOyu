//
//  TripDetail.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

/**************
 * **************包含三张单的所有数据************
 ****************/

#import <Foundation/Foundation.h>
#import "CityDestinationPoi.h"

@interface TripDetail : NSObject

@property (nonatomic, strong) id backUpJson;               //备份 json 串，用来生成备份路线

@property (nonatomic, copy) NSString *tripId;
@property (nonatomic, copy) NSString *tripTitle;
@property (nonatomic, strong) NSArray *destinations;       //保存目的地列表;
@property (nonatomic, strong) NSMutableArray *itineraryList;
@property (nonatomic, strong) NSMutableArray *shoppingList;
@property (nonatomic, strong) NSMutableArray *restaurantsList;
@property (nonatomic, strong) NSMutableArray *localityItems;
@property (nonatomic, strong) NSMutableArray *trafficItems;
@property (nonatomic, strong) NSMutableArray *travelNoteItems;

@property (nonatomic, strong) NSArray *images;
@property (nonatomic) NSInteger dayCount;         //行程单一共有几天
@property (nonatomic, copy) NSString *tripDetailUrl;   //分享用的 url

/**
 *  攻略是否发生了变化
 */
@property (nonatomic) BOOL tripIsChange;
- (id)initWithJson:(id)json;

- (TripDetail *)backUpTrip;

/**
 *  保存所有的路线，包含三张单的内容,但是你别小瞧了这个函数，这个函数可厉害了，他会自动判断你哪张单做了改动，要是没做改动是不会上传的。
 */
- (void)saveTrip:(void(^)(BOOL isSuccesss))completion;

/**
 *  保存攻略的目的地列表
 *
 *  @param completion 
 */
- (void)updateTripDestinations:(void(^)(BOOL isSuccesss))completion withDestinations:(NSArray *)destinations;

- (void)updateGuideTitle:(NSString *)title completed:(void (^)(BOOL isSuccess))completed;
@end








