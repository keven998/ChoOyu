//
//  CityHeaderView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityPoi.h"

@interface CityHeaderView : UIView

@property (nonatomic, strong) UIButton *favoriteBtn;

- (CGFloat)headerViewHightWithCityData:(CityPoi *)poi;


@end
