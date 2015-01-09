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

#import "ChatSendHelper.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "AccountManager.h"

@interface ChatImageOptions : NSObject<IChatImageOptions>

@property (assign, nonatomic) CGFloat compressionQuality;

@end

@implementation ChatImageOptions

@end

@implementation ChatSendHelper

//发送桃子旅行自定义的消息类型
+(EMMessage *)sendTaoziMessageWithString:(NSString *)mainStr
                           andExtMessage:(NSDictionary *)extMsg
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
{
    // 表情映射。
    NSString *willSendText = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:mainStr];
    EMChatText *text = [[EMChatText alloc] initWithText:willSendText];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    return [self sendMessage:username messageBody:body messageExt:extMsg isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

+(EMMessage *)sendTextMessageWithString:(NSString *)str
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
{
    // 表情映射。
    NSString *willSendText = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:str];
    EMChatText *text = [[EMChatText alloc] initWithText:willSendText];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

+(EMMessage *)sendImageMessageWithImage:(UIImage *)image
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
{
    EMChatImage *chatImage = [[EMChatImage alloc] initWithUIImage:image displayName:@"image.jpg"];
    id <IChatImageOptions> options = [[ChatImageOptions alloc] init];
    [options setCompressionQuality:0.75];
    [chatImage setImageOptions:options];

    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithImage:chatImage thumbnailImage:nil];

    return [self sendMessage:username messageBody:body  isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

+(EMMessage *)sendVoice:(EMChatVoice *)voice
             toUsername:(NSString *)username
            isChatGroup:(BOOL)isChatGroup
      requireEncryption:(BOOL)requireEncryption
{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

+(EMMessage *)sendVideo:(EMChatVideo *)video
             toUsername:(NSString *)username
            isChatGroup:(BOOL)isChatGroup
      requireEncryption:(BOOL)requireEncryption
{
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithChatObject:video];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

+(EMMessage *)sendLocationLatitude:(double)latitude
                         longitude:(double)longitude
                           address:(NSString *)address
                        toUsername:(NSString *)username
                       isChatGroup:(BOOL)isChatGroup
                 requireEncryption:(BOOL)requireEncryption
{
    EMChatLocation *chatLocation = [[EMChatLocation alloc] initWithLatitude:latitude longitude:longitude address:address];
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithChatObject:chatLocation];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

// 发送消息
+ (EMMessage *)sendMessage:(NSString *)username
              messageBody:(id<IEMMessageBody>)body
              isChatGroup:(BOOL)isChatGroup
        requireEncryption:(BOOL)requireEncryption
{
    return [self sendMessage:username messageBody:body messageExt:nil isChatGroup:isChatGroup requireEncryption:requireEncryption];
}

// 发送消息
+ (EMMessage *)sendMessage:(NSString *)username
              messageBody:(id<IEMMessageBody>)body
               messageExt:(NSDictionary *)extMsg
              isChatGroup:(BOOL)isChatGroup
        requireEncryption:(BOOL)requireEncryption
{
    EMMessage *retureMsg = [[EMMessage alloc] initWithReceiver:username bodies:[NSArray arrayWithObject:body]];
    NSMutableDictionary *allExtMsg = [[NSMutableDictionary alloc] init];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    //如果是群聊天，聊天信息里应该带上自己信息
    if (isChatGroup) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:accountManager.account.userId forKey:@"userId"];
        [userInfo setObject:accountManager.account.nickName forKey:@"nickName"];
        [userInfo setObject:accountManager.account.avatar forKey:@"avatar"];
        [allExtMsg setObject:userInfo forKey:@"fromUser"];
    }
    if (extMsg) {
        [allExtMsg addEntriesFromDictionary:extMsg];
    }
    retureMsg.ext = allExtMsg;
    retureMsg.requireEncryption = requireEncryption;
    retureMsg.isGroup = isChatGroup;
    EMMessage *message = [[EaseMob sharedInstance].chatManager asyncSendMessage:retureMsg progress:nil];

    return message;
}

+ (EMMessage *)sendCMDMessage:(NSString *)username
                  messageExt:(NSDictionary *)extMsg
                 isChatGroup:(BOOL)isChatGroup
           requireEncryption:(BOOL)requireEncryption
{
    EMChatCommand *cmd = [[EMChatCommand alloc] init];
    cmd.cmd = @"TZAction";
    EMCommandMessageBody *body = [[EMCommandMessageBody alloc] initWithChatObject:cmd];
    
    EMMessage *msg = [[EMMessage alloc]
                      initWithReceiver:username
                      bodies:[NSArray arrayWithObject:body]];
    msg.ext = extMsg;
    
    return [[EaseMob sharedInstance].chatManager asyncSendMessage:msg
                                                    progress:nil];
    return nil;
}


@end








