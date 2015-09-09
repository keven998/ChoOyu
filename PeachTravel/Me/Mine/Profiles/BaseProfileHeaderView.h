//
//  BaseProfileHeaderView.h
//  PeachTravel
//
//  Created by 王聪 on 15/9/6.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FrendModel,AccountModel;
@interface BaseProfileHeaderView : UIImageView

+ (BaseProfileHeaderView *)profileHeaderView;

@property (weak, nonatomic) UILabel *age;
@property (weak, nonatomic) UIImageView *sexImage;
@property (weak, nonatomic) UIImageView *constellation;
@property (weak, nonatomic) UILabel *city;
@property (weak, nonatomic) UIImageView *level;
@property (weak, nonatomic) UILabel *levelContent;

@property (weak, nonatomic) UILabel *nickName;
@property (weak, nonatomic) UIImageView *avatar;

@property (nonatomic, strong) FrendModel *userInfo;
@property (nonatomic, strong) AccountModel *accountModel;

@end
