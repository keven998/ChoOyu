//
//  GuiderProfileHeaderView.h
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FrendModel;

@interface GuiderProfileHeaderView : UIView

@property (weak, nonatomic) UILabel *age;
@property (weak, nonatomic) UIImageView *sexImage;
@property (weak, nonatomic) UILabel *constellation;
@property (weak, nonatomic) UILabel *city;

@property (weak, nonatomic) UIButton *friendBtn;
@property (weak, nonatomic) UIButton *sendBtn;

@property (weak, nonatomic) FrendModel *userInfo;

@end
