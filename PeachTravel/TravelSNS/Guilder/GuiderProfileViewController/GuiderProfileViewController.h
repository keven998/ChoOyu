//
//  GuiderProfileViewController.h
//  PeachTravel
//
//  Created by 王聪 on 8/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FrendModel;

@interface GuiderProfileViewController : TZViewController

@property (nonatomic) NSInteger userId;

//显示页内导航界面，如果是第一次进入的达人详情的话
@property (nonatomic) BOOL shouldShowExpertTipsView;

//@property (nonatomic, )

@end