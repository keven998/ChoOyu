//
//  TZCMDChatHelper.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/3.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "TZCMDChatHelper.h"
#import "AccountManager.h"

@implementation TZCMDChatHelper

/*
+ (EMMessage *)addContact:(NSString *)userName
     withAttachMsg:(NSString *)attachMsg
{
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] init];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [ext setObject:[NSNumber numberWithInt:CMDAddContact] forKey:@"CMDType"];
    
    NSMutableDictionary *contentDic = [[NSMutableDictionary alloc] init];
    [contentDic setObject:accountManager.account.userId forKey:@"userId"];
    [contentDic setObject:accountManager.account.nickName forKey:@"nickName"];
    [contentDic setObject:accountManager.account.avatar forKey:@"avatar"];
    [contentDic setObject:accountManager.account.avatarSmall forKey:@"avatarSmall"];
    [contentDic setObject:accountManager.account.gender forKey:@"gender"];
    [contentDic setObject:accountManager.account.easemobUser forKey:@"easemobUser"];
    [contentDic setObject:accountManager.account.signature forKey:@"signature"];
    [contentDic setObject:attachMsg forKey:@"attachMsg"];
    
    [ext setObject:contentDic forKey:@"content"];
    
    NSLog(@"加好友请求，请求内容为：%@", ext);
    
   return [ChatSendHelper sendCMDMessage:userName messageExt:ext isChatGroup:NO requireEncryption:NO];
}

+ (void)distributeCMDMsg:(EMMessage *)cmdMsg
{
    NSDictionary *extDic = cmdMsg.ext;
    NSInteger cmdType = [[extDic objectForKey:@"CMDType"] integerValue];
    switch (cmdType) {
        case CMDAddContact: {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            if ([[extDic objectForKey:@"content"] isKindOfClass:[NSString class]]) {
                NSData *data = [[extDic objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                [accountManager analysisAndSaveFrendRequest:jsonDic];

            } else if ([[extDic objectForKey:@"content"] isKindOfClass:[NSDictionary class]]) {
                [accountManager analysisAndSaveFrendRequest:[extDic objectForKey:@"content"]];
            }
        }
            break;
            
        case CMDAgreeAddContact: {       //添加好友后收到同意指令
            AccountManager *accountManager = [AccountManager shareAccountManager];
            
            NSDictionary *parseDic = [[NSDictionary alloc] init];
            if ([[extDic objectForKey:@"content"] isKindOfClass:[NSString class]]) {
                NSData *data = [[extDic objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                parseDic = jsonDic;
                
            } else if ([[extDic objectForKey:@"content"] isKindOfClass:[NSDictionary class]]) {
                parseDic = [extDic objectForKey:@"content"];
            }
            [accountManager addContact:parseDic];

            //如果收到同意好友的的联系人会话里已经有聊天记录了，那么就不添加下面的：“我已经同意。。。“的话了。
            NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
            for (EMConversation *conversation in conversations) {
                if ([conversation.chatter isEqualToString:[parseDic objectForKey:@"easemobUser"]]) {
                    if (!conversation.latestMessage) {
                        return;
                    }
                }
            }
            id  chatManager = [[EaseMob sharedInstance] chatManager];
            NSDictionary *loginInfo = [chatManager loginInfo];
            NSString *account = [loginInfo objectForKey:kSDKUsername];
            EMChatText *chatText = [[EMChatText alloc] initWithText:@"我已经同意了你的好友请求，现在可以分享旅行了"];
            EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
            EMMessage *message = [[EMMessage alloc] initWithReceiver:[parseDic objectForKey:@"easemobUser"] bodies:@[textBody]];
            [message setIsGroup:NO];
            [message setIsReadAcked:NO];
            [message setTo:account];
            [message setFrom:[parseDic objectForKey:@"easemobUser"]];
            [message setIsGroup:NO];
            message.conversationChatter = [parseDic objectForKey:@"easemobUser"];
            
            NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
            NSString *messageID = [NSString stringWithFormat:@"%.0f", interval];
            [message setMessageId:messageID];
            
            [chatManager importMessage:message
                           append2Chat:YES];
            
        }
            break;
            
        case CMDDeleteContact: {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            
            if ([[extDic objectForKey:@"content"] isKindOfClass:[NSString class]]) {
                NSData *data = [[extDic objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                [accountManager removeContact:[jsonDic objectForKey:@"userId"]];
                
            } else if ([[extDic objectForKey:@"content"] isKindOfClass:[NSDictionary class]]) {
                [accountManager removeContact:[[extDic objectForKey:@"content"] objectForKey:@"userId"]];
            }
        }
        default:
            break;
    }
}

*/

@end
