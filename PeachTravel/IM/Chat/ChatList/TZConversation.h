//
//  TZConversation.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/14/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//


@interface TZConversation : NSObject

/**
 *  如果是单聊的话获得单聊人的 nickname, 如果是群聊那么是群组的名称
 */
@property (nonatomic, copy) NSString *chatterNickName;

/**
 *  聊天人的头像
 */
@property (nonatomic, copy) NSString *chatterAvatar;

@property (nonatomic, strong) EMConversation *conversation;

@end
