//
//  TaoziChatMessageBaseViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/2/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@protocol TaoziMessageSendDelegate <NSObject>

- (void)sendSuccess:(ChatViewController *)chatCtl;

- (void)sendCancel;

@end

@interface TaoziChatMessageBaseViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *ratingBtn;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (nonatomic, copy) NSString *chatter;
@property (nonatomic) BOOL isGroup;
@property (nonatomic, copy) NSString *chatTitle;

@property (nonatomic, assign) id <TaoziMessageSendDelegate> delegate;

/**
 *  初始化一个不同种类的消息待发送界面
 *
 *  @param chatType 聊天的类型，分为景点，城市之类的
 *
 *  @return self
 */
- (id)initWithChatMessageType:(TZChatType)chatType;
@end

