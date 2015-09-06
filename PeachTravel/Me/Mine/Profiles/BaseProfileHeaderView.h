//
//  BaseProfileHeaderView.h
//  PeachTravel
//
//  Created by 王聪 on 15/9/6.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseProfileHeaderView : UIView

+ (BaseProfileHeaderView *)profileHeaderView;

@property (weak, nonatomic) UILabel *age;
@property (weak, nonatomic) UIImageView *sexImage;
@property (weak, nonatomic) UILabel *constellation;
@property (weak, nonatomic) UILabel *city;

@property (weak, nonatomic) UILabel *nickName;
@property (weak, nonatomic) UIImageView *avatar;

@end
