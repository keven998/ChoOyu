//
//  PlansListTableViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 15/6/18.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeachTravel-swift.h"

@interface PlansListTableViewController : UIViewController

- (id)initWithUserId:(NSInteger) userId;

/**
 *  进入此页面，点击每条攻略是发送还是进入详情，yes：发送
 */
@property (nonatomic) BOOL selectToSend;
@property (nonatomic) NSInteger chatterId;
@property (nonatomic) IMChatType chatType;

@property (nonatomic) NSInteger userId;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, assign) BOOL copyPatch; //复制补丁

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *selectGuides;
@property (nonatomic) BOOL canSelect;


@end
