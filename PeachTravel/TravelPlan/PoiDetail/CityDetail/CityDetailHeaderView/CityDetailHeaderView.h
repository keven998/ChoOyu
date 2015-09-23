//
//  CityDetailHeaderView.h
//  CityDetailHeaderView
//
//  Created by 冯宁 on 15/9/21.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityPoi.h"

@interface CityDetailHeaderView : UIView

@property (nonatomic, strong) CityPoi *cityPoi;

+ (CGFloat)headerHeight;

@end
