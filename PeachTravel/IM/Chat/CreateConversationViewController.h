//
//  CreateConversationViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/31.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@protocol CreateConversationDelegate <NSObject>

@optional

/**
 *  创建会话成功的 delegate
 *
 *  @param chatter 会话的 chatterid
 *  @param isGroup 是否是群
 *  @param chatTitle 聊天界面显示的title
 */
- (void)createConversationSuccessWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup chatTitle:(NSString *)chatTitle;

@end

@interface CreateConversationViewController : TZViewController

/**
 *  FM群组
 */
@property (nonatomic, strong) Group *group;

/**
 *  环信的群组
 */
@property (nonatomic, strong) EMGroup *emGroup;

@property (nonatomic, assign) id <CreateConversationDelegate> delegate;

@property (nonatomic) BOOL isPushed;

@end
