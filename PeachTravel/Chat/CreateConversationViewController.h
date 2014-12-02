//
//  CreateConversationViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/31.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "ChatViewController.h"

@protocol CreateConversationDelegate <NSObject>

@optional

/**
 *  创建会话成功的 delegate
 *
 *  @param chatter 会话的 chatterid
 *  @param isGroup 是否是群
 */
- (void)createConversationSuccessWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;

@end

@interface CreateConversationViewController : UIViewController

@property (nonatomic, strong) Group *group;

@property (nonatomic, assign) id <CreateConversationDelegate> delegate;
@end
