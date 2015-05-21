//
//  TaoziChatMessageBaseViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/2/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import "PeachTravel-swift.h"

@protocol TaoziMessageSendDelegate <NSObject>

- (void)sendSuccess:(ChatViewController *)chatCtl;

- (void)sendCancel;

@end

@interface TaoziChatMessageBaseViewController : TZViewController

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *propertyBtn;

@property (nonatomic) NSInteger chatterId;
@property (nonatomic) IMChatType chatType;
@property (nonatomic, copy) NSString *chatTitle;
// chatType 聊天的类型，分为景点，城市之类的
@property (nonatomic) IMMessageType messageType;

//发送内容的 id,景点 id，攻略 id 之类的
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *messageDetailUrl;
@property (nonatomic, copy) NSString *messageImage;
@property (nonatomic, copy) NSString *messageName;
@property (nonatomic, copy) NSString *messageDesc;
@property (nonatomic, copy) NSString *messagePrice;
@property (nonatomic) float messageRating;
@property (nonatomic, copy) NSString *messageAddress;
@property (nonatomic, copy) NSString *messageTimeCost;

@property (nonatomic, weak) id <TaoziMessageSendDelegate> delegate;


@end

