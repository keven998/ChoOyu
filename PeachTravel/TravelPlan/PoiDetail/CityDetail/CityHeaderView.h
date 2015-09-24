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
{
    CityPoi* _cityPoi;
}

@property (nonatomic, strong) UIButton *showTipsBtn;
@property (nonatomic, strong) UIButton *showSpotsBtn;
@property (nonatomic, strong) UIButton *showRestaurantsBtn;
@property (nonatomic, strong) UIButton *showShoppingBtn;
@property (nonatomic, strong) UILabel *cityDesc;
@property (nonatomic, strong) UILabel *travelMonth;


@property (nonatomic, strong) CityPoi *cityPoi;

@end
