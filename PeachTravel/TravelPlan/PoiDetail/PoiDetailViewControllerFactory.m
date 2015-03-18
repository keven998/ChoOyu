//
//  PoiDetailViewControllerFactory.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "PoiDetailViewControllerFactory.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "HotelDetailViewController.h"
#import "CityDetailTableViewController.h"
#import "SpotDetailViewController.h"

@implementation PoiDetailViewControllerFactory

+ (CommonPoiDetailViewController *)poiDetailViewControllerWithPoiType:(TZPoiType)poiType
{
    CommonPoiDetailViewController *retCtl;
    
    if (poiType == kHotelPoi) {
        retCtl = [[HotelDetailViewController alloc] init];
    } else if (poiType == kRestaurantPoi) {
        retCtl = [[RestaurantDetailViewController alloc] init];
    } else if (poiType == kShoppingPoi) {
        retCtl = [[ShoppingDetailViewController alloc] init];
    }
    
    return retCtl;
}

@end
