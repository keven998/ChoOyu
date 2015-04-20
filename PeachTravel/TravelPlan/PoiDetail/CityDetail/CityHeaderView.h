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

@property (nonatomic, strong) TZButton *showTipsBtn;
@property (nonatomic, strong) TZButton *showSpotsBtn;
@property (nonatomic, strong) TZButton *showRestaurantsBtn;
@property (nonatomic, strong) TZButton *showShoppingBtn;

- (CGFloat)headerViewHightWithCityData:(CityPoi *)poi;

@property (nonatomic, strong) CityPoi *cityPoi;

@property (nonatomic, weak) id <CityHeaderViewDelegate>delegate;




@end
