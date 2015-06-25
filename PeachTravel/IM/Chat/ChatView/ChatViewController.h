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

- (instancetype)initWithChatter:(NSInteger)chatter chatType:(IMChatType)chatType;
- (instancetype)initWithConversation:(ChatConversation *)conversation;

@end
