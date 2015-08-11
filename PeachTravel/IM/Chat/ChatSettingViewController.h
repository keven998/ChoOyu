//
//  ChatSettingViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/6/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeachTravel-swift.h"

@interface ChatSettingViewController : TZViewController

@property (nonatomic) NSInteger chatterId;
@property (nonatomic, strong) ChatConversation *currentConversation;

@property (nonatomic, weak) UIViewController *containerCtl;

@end
