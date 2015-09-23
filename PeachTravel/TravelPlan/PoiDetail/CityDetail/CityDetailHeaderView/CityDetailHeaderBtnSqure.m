//
//  CityDetailHeaderBtnSqure.m
//  CityDetailHeaderView
//
//  Created by 冯宁 on 15/9/22.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "CityDetailHeaderBtnSqure.h"
#import "ArgumentsOfCityDetailHeaderView.h"
#import "Constants.h"

@interface CityDetailHeaderBtnSqure ()

@property (nonatomic, assign) CGFloat imageViewLeft;

@end

@implementation CityDetailHeaderBtnSqure

+ (instancetype)buttonWithType:(UIButtonType)buttonType{
    CityDetailHeaderBtnSqure* btn = [super buttonWithType:buttonType];
    [btn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    return btn;
}

@end
