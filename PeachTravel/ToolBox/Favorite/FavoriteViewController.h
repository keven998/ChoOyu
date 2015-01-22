//
//  FavoriteViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteViewController : UITableViewController

/**
 *  进入此页面，点击每条攻略是发送还是进入详情，yes：发送
 */
@property (nonatomic) BOOL selectToSend;

@property (nonatomic, copy) NSString *chatter;

@property (nonatomic) BOOL isChatGroup;


@end
