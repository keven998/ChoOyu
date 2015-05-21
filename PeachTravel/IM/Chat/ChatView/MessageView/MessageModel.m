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

#import "MessageModel.h"




@implementation MessageModel

- (instancetype)initWithBaseMessage:(BaseMessage *)message
{
    self = [super init];
    if (self) {
        _type = message.messageType;
        _status = message.status;
        _timestamp = message.createTime;
        _content = message.message;
        if (message.chatType == IMChatTypeIMChatSingleType) {
            _isChatGroup = NO;
        } else {
            _isChatGroup = YES;
        }
        
        switch (message.messageType) {
            case IMMessageTypeAudioMessageType:
                _localPath = ((AudioMessage *)message).localPath;
                _remotePath = ((AudioMessage *)message).remoteUrl;
                _time = ((AudioMessage *)message).audioLength;
                _localPath = ((AudioMessage *)message).localPath;
                _isRead = ((AudioMessage *)message).audioStatus == IMAudioStatusReaded ? YES : NO;

                
                break;
                
            case IMMessageTypeImageMessageType:
                _thumbnailSize = CGSizeMake(((ImageMessage *)message).imageWidth, ((ImageMessage *)message).imageHeight);
                _imageRemoteURL = [NSURL URLWithString:((ImageMessage *)message).fullUrl];
                _thumbnailRemoteURL = [NSURL URLWithString:((ImageMessage *)message).thumbUrl];
                _image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:((ImageMessage *)message).localPath]]];
                break;
                
            case IMMessageTypeLocationMessageType:
                _address = ((LocationMessage *)message).address;
                _latitude = ((LocationMessage *)message).latitude;
                _longitude = ((LocationMessage *)message).longitude;
                
            default:
                break;
        }
    }
    
    return self;
}


@end
