//
//  CommonPoiDetailView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiSummary.h"

@interface CommonPoiDetailView : UIView

@property (nonatomic, strong) PoiSummary *poi;

@property (nonatomic, weak) UIViewController *rootCtl;

@property (nonatomic, strong) UIButton *shareBtn;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic) TZPoiType poiType;

@end
