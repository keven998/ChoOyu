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

@interface TripDetail : NSObject

@property (nonatomic, strong) id backUpJson;               //备份 json 串，用来生成备份路线
@property (nonatomic, strong) TripDetail *backUpTrip;      //备份路线

@property (nonatomic, copy) NSString *tripId;
@property (nonatomic, copy) NSString *tripTitle;
@property (nonatomic, strong) NSArray *itineraryList;
@property (nonatomic, strong) NSArray *shoppingList;
@property (nonatomic, strong) NSArray *restaurantsList;
@property (nonatomic) NSInteger *dayCount;         //行程单一共有几天

- (id)initWithJson:(id)json;

/**
 *  保存所有的路线，包含三张单的内容,但是你别小瞧了这个函数，这个函数可厉害了，他会自动判断你哪张单做了改动，要是没做改动是不会上传的。
 */
- (void)saveTrip;

@end
