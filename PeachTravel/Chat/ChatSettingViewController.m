//
//  ChatSettingViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/5.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChatSettingViewController.h"
#import "AccountManager.h"
#import "ChatSendHelper.h"
#import "ChangeGroupTitleViewController.h"

@interface ChatSettingViewController () <IChatManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *groupTitle;

@end

@implementation ChatSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_groupTitle setTitle:_group.groupSubject forState:UIControlStateNormal];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    //只有管理员可以修改群组名称
    if ([_group.owner isEqualToString: accountManager.account.easemobUser]) {
        _groupTitle.userInteractionEnabled = YES;
    } else {
        _groupTitle.userInteractionEnabled = NO;
    }
    
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    for (EMGroup *tempGroup in [[EaseMob sharedInstance].chatManager groupList]) {
        if ([_group.groupId isEqualToString:tempGroup.groupId]) {
            _group = tempGroup;
            break;
        }
    }
    [_groupTitle setTitle:_group.groupSubject forState:UIControlStateNormal];
}

//当退出一个群组，向群里发送一条退出语句
- (void)sendMsgWhileQuit
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    NSString *messageStr = [NSString stringWithFormat:@"%@退出了群组",accountManager.account.nickName];
    
    NSDictionary *messageDic = @{@"tzType":@100, @"content":messageStr};
    
    [ChatSendHelper sendTaoziMessageWithString:messageStr andExtMessage:messageDic toUsername:_group.groupId isChatGroup:YES requireEncryption:NO];
}

- (IBAction)changeMsgStatus:(UIButton *)sender {
}

- (IBAction)changeGroupTitle:(UIButton *)sender {
    ChangeGroupTitleViewController *changeCtl = [[ChangeGroupTitleViewController alloc] init];
    changeCtl.groupId = _group.groupId;
    changeCtl.oldTitle = _group.groupSubject;
    [self.navigationController pushViewController:changeCtl animated:YES];
}

- (IBAction)deleteMsg:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认删除" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:_group.groupId];

        }
    }];
}

- (IBAction)quitGroup:(UIButton *)sender {
    [self showHudInView:self.view hint:@"退出群组"];
    [self sendMsgWhileQuit];
    
}

- (IBAction)upChatList:(UIButton *)sender {
}

#pragma mark - IChatManagerDelegate

-(void)didSendMessage:(EMMessage *)message error:(EMError *)error;
{
    NSLog(@"发送退出小组指令成功");
    __weak typeof(self) weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_group.groupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
        [weakSelf hideHud];
        if (error) {
            [weakSelf showHint:@"退出群组失败"];
        }
        else{
            NSLog(@"退出小组成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
        }
    } onQueue:nil];
}



@end
