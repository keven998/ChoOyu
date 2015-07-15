//
//  ChatViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 5/25/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeachTravel-swift.h"

@interface ChatViewController : TZViewController

@property (nonatomic, copy) NSString *chatterName;
@property (nonatomic, weak) UIViewController *containerCtl;

typedef void(^BackBlock)();

- (instancetype)initWithChatter:(NSInteger)chatter chatType:(IMChatType)chatType;
- (instancetype)initWithConversation:(ChatConversation *)conversation;

/**
 *  点击返回按钮需要执行的操作
 */
@property (nonatomic, copy) BackBlock backBlock;

@end
