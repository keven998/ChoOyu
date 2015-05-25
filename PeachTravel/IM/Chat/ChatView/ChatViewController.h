//
//  ChatViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 5/25/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : TZViewController

- (instancetype)initWithChatter:(NSInteger)chatter chatType:(IMChatType)chatType;

- (instancetype)initWithConversation:(ChatConversation *)conversation;

@property (nonatomic, copy) NSString *chatterNickName;
@property (nonatomic, copy) NSString *chatterAvatar;

@end
