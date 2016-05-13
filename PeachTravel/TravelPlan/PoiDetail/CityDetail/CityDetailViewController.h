//
//  CityDetailViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/4/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityDetailViewController : TZViewController

@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *cityName;

@property (nonatomic) BOOL isCountry;
@end
