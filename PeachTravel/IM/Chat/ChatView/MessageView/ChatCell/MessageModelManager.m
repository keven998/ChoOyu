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

#import "MessageModelManager.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "MessageModel.h"
#import "EaseMob.h"
#import "AccountManager.h"

@implementation MessageModelManager

+ (id)modelWithMessage:(EMMessage *)message
{
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    NSDictionary *userInfo = [[EaseMob sharedInstance].chatManager loginInfo];
    NSString *login = [userInfo objectForKey:kSDKUsername];
    BOOL isSender = [login isEqualToString:message.from] ? YES : NO;
    
    MessageModel *model = [[MessageModel alloc] init];
    model.isRead = message.isRead;
    model.messageBody = messageBody;
    model.message = message;
    model.type = messageBody.messageBodyType;
    model.messageId = message.messageId;
    model.timestamp = message.timestamp;
    model.isSender = isSender;
    model.isPlaying = NO;
    model.isChatGroup = message.isGroup;
    if (model.isChatGroup) {
        model.nickName = [[message.ext objectForKey:@"fromUser"] objectForKey:@"nickName"];
        model.username = message.groupSenderName;
    } else{
        model.username = message.from;
    }
    
    if (isSender) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        model.headImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", accountManager.account.avatarSmall]];
        model.status = message.deliveryState;
    } else{
        if (model.isChatGroup) {
            model.headImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [[message.ext objectForKey:@"fromUser"] objectForKey:@"avatar"]]];
        }
        model.status = eMessageDeliveryState_Delivered;
    }
    
    switch (messageBody.messageBodyType) {
        case eMessageBodyType_Text:
        {
            //如果是原生的文字消息类型
            if (!message.ext || [[message.ext objectForKey:@"tzType"] integerValue] == TZChatNormalText) {
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                model.content = didReceiveText;
                
            } else {        //如果是旅行派自定义的消息类型
                model.taoziMessage = message.ext;
                model.type = eMessageBodyType_Taozi;
            }
        }
            break;
            
        case eMessageBodyType_Image:
        {
            EMImageMessageBody *imgMessageBody = (EMImageMessageBody*)messageBody;
            model.thumbnailSize = imgMessageBody.thumbnailSize;
            model.size = imgMessageBody.size;
            model.localPath = imgMessageBody.localPath;
            model.thumbnailImage = [UIImage imageWithContentsOfFile:imgMessageBody.thumbnailLocalPath];
            if (isSender)
            {
                model.image = [UIImage imageWithContentsOfFile:imgMessageBody.thumbnailLocalPath];
            }else {
                model.imageRemoteURL = [NSURL URLWithString:imgMessageBody.remotePath];
            }
        }
            break;
        case eMessageBodyType_Location:
        {
            model.content = @"升级新版本才可以查看这条神秘消息哦";
            model.address = ((EMLocationMessageBody *)messageBody).address;
            model.latitude = ((EMLocationMessageBody *)messageBody).latitude;
            model.longitude = ((EMLocationMessageBody *)messageBody).longitude;
        }
            break;
        case eMessageBodyType_Voice:
        {
            model.time = ((EMVoiceMessageBody *)messageBody).duration;
            model.chatVoice = (EMChatVoice *)((EMVoiceMessageBody *)messageBody).chatObject;
            if (message.ext) {
                NSDictionary *dict = message.ext;
                BOOL isPlayed = [[dict objectForKey:@"isPlayed"] boolValue];
                model.isPlayed = isPlayed;
            }else {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@NO,@"isPlayed", nil];
                message.ext = dict;
                [message updateMessageExtToDB];
            }
            // 本地音频路径
            model.localPath = ((EMVoiceMessageBody *)messageBody).localPath;
            model.remotePath = ((EMVoiceMessageBody *)messageBody).remotePath;
        }
            break;
        case eMessageBodyType_Video:{
            model.content = @"升级新版本才可以查看这条神秘消息哦";
            EMVideoMessageBody *videoMessageBody = (EMVideoMessageBody*)messageBody;
            model.thumbnailSize = videoMessageBody.size;
            model.size = videoMessageBody.size;
            model.localPath = videoMessageBody.thumbnailLocalPath;
            model.thumbnailImage = [UIImage imageWithContentsOfFile:videoMessageBody.thumbnailLocalPath];
            model.image = model.thumbnailImage;
        }
            break;

        default: {
            model.content = @"升级新版本才可以查看这条神秘消息哦";
        }
            break;
    }
    
    return model;
}

@end
