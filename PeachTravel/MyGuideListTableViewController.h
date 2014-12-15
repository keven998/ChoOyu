//
//  MyGuideListTableViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/28/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "ChatViewController.h"

@interface MyGuideListTableViewController : UIViewController

/**
 *  进入此页面，点击每条攻略是发送还是进入详情，yes：发送
 */
@property (nonatomic) BOOL selectToSend;

@property (nonatomic, weak) ChatViewController *chatCtl;



@end
