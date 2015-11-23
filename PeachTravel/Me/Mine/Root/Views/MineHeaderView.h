//
//  MineHeaderView.h
//  PeachTravel
//
//  Created by 王聪 on 15/9/2.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AccountModel;

@interface MineHeaderView : UIView

@property (nonatomic, weak) UIViewController *containerViewController;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *avatarImageViewBG;
@property (nonatomic, strong) UILabel *nickNameLabel;

@property (nonatomic, strong) AccountModel *account;

@end
