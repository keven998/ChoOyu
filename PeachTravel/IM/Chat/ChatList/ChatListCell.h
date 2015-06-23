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

typedef enum : NSUInteger {
    MSGSended = 1,
    MSGSending,
    MSGSendFaild,
} MSG_SEND_STATUS;

@interface ChatListCell : UITableViewCell
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *placeholderImageUrl;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detailMsg;
@property (nonatomic, strong) NSString *time;
@property (nonatomic) NSInteger unreadCount;
@property (nonatomic) MSG_SEND_STATUS sendStatus;

@end
