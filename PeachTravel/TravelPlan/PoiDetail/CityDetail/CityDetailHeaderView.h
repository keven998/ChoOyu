//
//  CityHeaderView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityPoi.h"

@interface CityDetailHeaderView : UIView

@property (nonatomic, strong) CityPoi *cityPoi;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, weak) UIViewController *containerViewController;

@end
