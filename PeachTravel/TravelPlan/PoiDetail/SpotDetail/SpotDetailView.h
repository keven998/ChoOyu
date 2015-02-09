//
//  SpotDetailView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotPoi.h"

@interface SpotDetailView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) SpotPoi *spot;

@property (nonatomic, strong) UIButton *travelGuideBtn;
@property (nonatomic, strong) UIButton *kendieBtn;
@property (nonatomic, strong) UIButton *trafficGuideBtn;
@property (nonatomic, strong) UIButton *favoriteBtn;
@property (nonatomic, strong) UIButton *descDetailBtn;
@property (nonatomic, strong) UIButton *travelBtn;
@property (nonatomic, strong) UIButton *ticketBtn;

@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *addressBtn;
@property (nonatomic, strong) UIButton *closeBtn;

@end
