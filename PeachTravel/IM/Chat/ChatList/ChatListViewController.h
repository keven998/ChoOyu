//
//  ChatListViewController
//  PeachTravel
//
//  Created by liangpengshuai on 5/25/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UnreadMessageCountChangeDelegate <NSObject>

/**
 *  未读消息的数量发生变化
 *
 *  @param unreadCount 
 */
- (void)unreadMessageCountHasChange;

@end

@interface ChatListViewController : TZViewController

/**
 *  链接状态
 */
@property (nonatomic) IM_CONNECT_STATE IMState;

@property (nonatomic, weak) id <UnreadMessageCountChangeDelegate> delegate;

@end

