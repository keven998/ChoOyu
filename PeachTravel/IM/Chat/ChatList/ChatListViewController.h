//
//  ChatListViewController
//  PeachTravel
//
//  Created by liangpengshuai on 5/25/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListViewController : TZViewController

- (void)networkChanged:(EMConnectionState)connectionState;

/**
 *  未读的聊天消息
 */
@property (nonatomic) int numberOfUnReadChatMsg;

/**
 *  链接状态
 */
@property (nonatomic) IM_CONNECT_STATE IMState;

@end

