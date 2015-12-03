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

#import <Foundation/Foundation.h>
#import "PeachTravel-swift.h"
#import "GoodsDetailModel.h"

#define KFIRETIME 20

@interface MessageModel : NSObject
{
    BOOL _isPlaying;
}

@property (nonatomic) IMMessageType type;
@property (nonatomic) IMMessageStatus status;
@property (nonatomic) NSInteger senderId; //消息的发送者

@property (nonatomic) BOOL isSender;    //是否是发送者
@property (nonatomic) BOOL isRead;      //是否已读
@property (nonatomic) IMChatType chatType;  //聊天类型

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSURL *headImageURL;
@property (nonatomic, strong) NSString *nickName;
/*!
 @property
 @brief 消息发送或接收的时间
 */
@property (nonatomic) long long timestamp;


//text
@property (nonatomic, strong) NSString *content;

//旅行派自有的消息内容
@property (nonatomic, strong) IMPoiModel *poiModel;

//消息中包含的商品信息
@property (nonatomic, strong) GoodsDetailModel *goodsModel;


//image
@property (nonatomic) CGSize size;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic, strong) NSURL *imageRemoteURL;
@property (nonatomic, strong) NSURL *thumbnailRemoteURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;

//audio
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) NSString *remotePath;
@property (nonatomic) float time;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isPlayed;

//location
@property (nonatomic, strong) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic, strong) BaseMessage *baseMessage;

- (instancetype)initWithBaseMessage:(BaseMessage *)message;

@end



