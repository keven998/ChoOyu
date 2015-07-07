//
//  ChatGroupSettingViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/5.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeachTravel-swift.h"

@interface ChatGroupSettingViewController : UIViewController

@property (nonatomic) NSInteger groupId;

@property (nonatomic, weak) UIViewController *containerCtl;

@property (nonatomic, strong) ChatConversation *conversation;

@end
