//
//  TripDetailRootViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RDVTabBarController.h"
#import "TripDetail.h"

@interface TripDetailRootViewController : RDVTabBarController

@property (nonatomic, strong) TripDetail *tripDetail;
@property (nonatomic, strong) NSArray *destinations;

@property (nonatomic) BOOL isMakeNewTrip;    //进入三账单会有两种情况，一种是传目的地列表新制作攻略，另一种是传攻略 id 来查看攻略

@property (nonatomic, copy) NSString *tripId;

@end
