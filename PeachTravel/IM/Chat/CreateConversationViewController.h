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

- (void)createConversationSuccessWithChatter:(NSInteger)chatterId chatType:(IMChatType)chatType chatTitle:(NSString *)chatTitle;
-(void)reloadData;

@end

@interface CreateConversationViewController : TZViewController

/**
 *  旅行派群组
 */
@property (nonatomic, strong) Group *group;

/**
 *  环信的群组
 */
@property (nonatomic, strong) EMGroup *emGroup;

@property (nonatomic, weak) id <CreateConversationDelegate> delegate;

@property (nonatomic) BOOL isPushed;

@end
