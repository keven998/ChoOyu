//
//  MakePlanViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "MHTabBarController.h"
#import "CityDestinationPoi.h"
#import "DestinationToolBar.h"
#import "Destinations.h"

@interface MakePlanViewController : MHTabBarController

@property (nonatomic, strong) DestinationToolBar *destinationToolBar;
@property (nonatomic, strong) Destinations *destinations;



@end
