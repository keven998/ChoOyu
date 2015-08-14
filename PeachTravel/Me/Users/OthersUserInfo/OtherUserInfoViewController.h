//
//  OtherUserInfoViewController.h
//  PeachTravel
//
//  Created by dapiao on 15/5/16.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherUserInfoViewController : TZViewController

@property (nonatomic) NSInteger userId;

//显示页内导航界面，如果是第一次进入的达人详情的话
@property (nonatomic) BOOL shouldShowExpertTipsView;

@end
