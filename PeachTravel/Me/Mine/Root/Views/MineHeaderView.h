//
//  MineHeaderView.h
//  PeachTravel
//
//  Created by 王聪 on 15/9/2.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AccountModel;

@interface MineHeaderView : UIImageView

@property (nonatomic, weak) UIImageView *avatar;
@property (nonatomic, weak) UILabel *nickName;
@property (nonatomic, weak) UILabel *userId;
@property (nonatomic, weak) UILabel *sex;
@property (nonatomic, weak) UILabel *costellation;
@property (nonatomic, weak) UILabel *level;

@property (nonatomic, strong) AccountModel *account;

@property (nonatomic, strong) UIView *contentView;

@end
