//
//  CityListTableViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityListTableViewController : UIViewController

@property (nonatomic, strong) NSArray *cityDataSource;

/**
 *  是否需要定位用户位置
 */
@property (nonatomic) BOOL needUserLocation;

@end
