//
//  TZCMDChatHelper.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/3.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "TZCMDChatHelper.h"
#import "Chat/ChatView/ChatSendHelper.h"
#import "AccountManager.h"
#import "AccountManager.h"

@implementation TZCMDChatHelper

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
    [contentDic setObject:accountManager.account.gender forKey:@"gender"];
    [contentDic setObject:accountManager.account.easemobUser forKey:@"easemobUser"];
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
            [accountManager analysisAndSaveFrendRequest:[extDic objectForKey:@"content"]];
        }
            break;
            
        case CMDAgreeAddContact: {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager addContact:[extDic objectForKey:@"content"]];
        }
            break;
            
        case CMDDeleteContact: {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager removeContact:[[extDic objectForKey:@"content"] objectForKey:@"userId"]];
        }
        default:
            break;
    }
}

@end
