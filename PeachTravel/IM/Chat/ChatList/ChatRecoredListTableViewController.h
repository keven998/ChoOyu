//
//  ChatRecoredListTableViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/1/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateConversationViewController.h"

@protocol ChatRecordListDelegate <NSObject>

@optional

- (void)choseReceiverOver;

@end

@interface ChatRecoredListTableViewController :TZTableViewController

@property (nonatomic, weak) id <CreateConversationDelegate> delegate;

@end
