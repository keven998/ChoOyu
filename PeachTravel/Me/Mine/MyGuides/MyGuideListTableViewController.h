//
//  MyGuideListTableViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/28/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeachTravel-swift.h"

@interface MyGuideListTableViewController : UIViewController

/**
 *  进入此页面，点击每条攻略是发送还是进入详情，yes：发送
 */
@property (nonatomic) BOOL selectToSend;
@property (nonatomic) NSInteger chatterId;
@property (nonatomic) IMChatType chatType;

@property (nonatomic, assign) BOOL isTrip;


/**
 *  自己查看为NO  查看达人为YES
 */
@property (nonatomic) BOOL isExpert;

@property (nonatomic,copy) NSNumber *userId;
@end
