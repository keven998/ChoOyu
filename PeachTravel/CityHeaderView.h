//
//  CityHeaderView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityPoi.h"

@protocol CityHeaderViewDelegate <NSObject>

- (void)updateCityHeaderView;

@end

@interface CityHeaderView : UIView

@property (nonatomic, strong) UIButton *favoriteBtn;
@property (nonatomic, strong) UIButton *showSpotsBtn;
@property (nonatomic, strong) UIButton *showRestaurantsBtn;
@property (nonatomic, strong) UIButton *showShoppingBtn;


- (CGFloat)headerViewHightWithCityData:(CityPoi *)poi;

@property (nonatomic, strong) CityPoi *cityPoi;

@property (nonatomic, assign) id <CityHeaderViewDelegate>delegate;


@end
