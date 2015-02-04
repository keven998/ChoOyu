/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>

@interface ChatViewController : TZViewController

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;

@property (nonatomic, copy) NSString *chatterNickName;
@property (nonatomic, copy) NSString *chatterAvatar;

/**
 *  发送桃子旅行消息
 *
 *  @param taoziMsg 桃子旅行
 */
- (void)sendTaoziMessage:(NSDictionary *)taoziMsg;
@end