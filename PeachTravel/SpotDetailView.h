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

@end
