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
#import "ConvertToCommonEmoticonsHelper.h"

@implementation MessageModel

- (instancetype)initWithBaseMessage:(BaseMessage *)message
{
    self = [super init];
    if (self) {
        _baseMessage = message;
        _type = message.messageType;
        _status = message.status;
        _timestamp = message.createTime;
        _content = message.message;
        _chatType = message.chatType;
       
        if (message.sendType == IMMessageSendTypeMessageSendMine) {
            _isSender = YES;
        } else {
            _isSender = NO;
        }
        
        _senderId = message.senderId;
        
        switch (message.messageType) {
            case IMMessageTypeTextMessageType: {
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:message.message];
                _content = didReceiveText;
            }

                break;
            case IMMessageTypeAudioMessageType:
                _localPath = ((AudioMessage *)message).localPath;
                _remotePath = ((AudioMessage *)message).remoteUrl;
                _time = ((AudioMessage *)message).audioLength;
                _localPath = ((AudioMessage *)message).localPath;
                _isPlayed = ((AudioMessage *)message).audioStatus == IMAudioStatusReaded ? YES : NO;
                
                break;
                
            case IMMessageTypeImageMessageType:
                _thumbnailSize = CGSizeMake(((ImageMessage *)message).imageWidth, ((ImageMessage *)message).imageHeight);
                _size = CGSizeMake(((ImageMessage *)message).imageWidth, ((ImageMessage *)message).imageHeight);
                _imageRemoteURL = [NSURL URLWithString:((ImageMessage *)message).fullUrl];
                _thumbnailRemoteURL = [NSURL URLWithString:((ImageMessage *)message).thumbUrl];
                _image = [UIImage imageWithContentsOfFile:((ImageMessage*)message).localPath];
                break;
                
            case IMMessageTypeLocationMessageType:
                _localPath = ((LocationMessage *)message).localPath;
                _address = ((LocationMessage *)message).address;
                _latitude = ((LocationMessage *)message).latitude;
                _longitude = ((LocationMessage *)message).longitude;
                _image = [UIImage imageWithContentsOfFile:((ImageMessage*)message).localPath];
                break;
                
            case IMMessageTypeTravelNoteMessageType:
                _poiModel = ((IMTravelNoteMessage *) message).poiModel;
                break;
                
            case IMMessageTypeCityPoiMessageType:
                _poiModel = ((IMCityMessage *) message).poiModel;

                break;
            case IMMessageTypeShoppingMessageType:
                _poiModel = ((IMShoppingMessage *) message).poiModel;

                break;

            case IMMessageTypeHotelMessageType:
                _poiModel = ((IMHotelMessage *) message).poiModel;

                break;

            case IMMessageTypeRestaurantMessageType:
                _poiModel = ((IMRestaurantMessage *) message).poiModel;

                break;

            case IMMessageTypeGuideMessageType:
                _poiModel = ((IMGuideMessage *) message).poiModel;

                break;

            case IMMessageTypeSpotMessageType:
                _poiModel = ((IMSpotMessage *) message).poiModel;
                break;
                
            case IMMessageTypeTipsMessageType:
                _content = ((TipsMessage *) message).tipsContent;

                break;
                
            default:
                break;
        }
    }
    
    return self;
}


@end
