//
//  ChatSettingViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/5.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChatGroupSettingViewController.h"
#import "AccountManager.h"
#import "ChatSendHelper.h"
#import "ChangeGroupTitleViewController.h"

@interface ChatGroupSettingViewController () <IChatManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *groupTitle;
@property (weak, nonatomic) IBOutlet UIButton *quitBtn;
/**
 *  
 */
@property (weak, nonatomic) IBOutlet UIImageView *groupMsgStatusImageView;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;

@property (nonatomic) BOOL isPushNotificationEnable;

@end

@implementation ChatGroupSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"讨论组设置";
    [_groupTitle setTitle:_group.groupSubject forState:UIControlStateNormal];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    //只有管理员可以修改群组名称
    if ([_group.owner isEqualToString: accountManager.account.easemobUser]) {
        _groupTitle.userInteractionEnabled = YES;
        [_quitBtn setTitle:@"解散该群" forState:UIControlStateNormal];
    } else {
        _groupTitle.userInteractionEnabled = NO;
        _accessoryImageView.hidden = YES;
        [_quitBtn setTitle:@"退出该群" forState:UIControlStateNormal];
    }

    if ( _group.isPushNotificationEnabled) {
        _isPushNotificationEnable = YES;
        [_groupMsgStatusImageView setImage:[UIImage imageNamed:@"check_border.png"]];
    } else {
        _isPushNotificationEnable = NO;
        [_groupMsgStatusImageView setImage:[UIImage imageNamed:@"check_selected.png"]];

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

/**
 *  当退出一个群组，向群里发送一条退出语句
 */
- (void)sendMsgWhileQuit
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    NSString *messageStr = [NSString stringWithFormat:@"%@退出了群组",accountManager.account.nickName];
    
    NSDictionary *messageDic = @{@"tzType":[NSNumber numberWithInt:TZTipsMsg], @"content":messageStr};
    
    [ChatSendHelper sendTaoziMessageWithString:messageStr andExtMessage:messageDic toUsername:_group.groupId isChatGroup:YES requireEncryption:NO];
}

/**
 *  更新群组消息提醒状态，屏蔽和不屏蔽
 *
 *  @param sender
 */
- (IBAction)changeMsgStatus:(UIButton *)sender {
    __weak ChatGroupSettingViewController *weakSelf = self;
    sender.userInteractionEnabled = NO;
    [self showHudInView:self.view hint:@"正在设置"];
    [[EaseMob sharedInstance].chatManager asyncIgnoreGroupPushNotification:_group.groupId isIgnore:_isPushNotificationEnable completion:^(NSArray *ignoreGroupsList, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            [weakSelf showHint:@"设置成功"];
            _isPushNotificationEnable = !_isPushNotificationEnable;
            NSString *imageName = _isPushNotificationEnable? @"check_border.png":@"check_selected.png";
            [_groupMsgStatusImageView setImage:[UIImage imageNamed:imageName]];
        }
        else{
            [weakSelf showHint:@"设置失败"];
        }
        sender.userInteractionEnabled = YES;
    } onQueue:nil];

}

- (IBAction)changeGroupTitle:(UIButton *)sender {
    ChangeGroupTitleViewController *changeCtl = [[ChangeGroupTitleViewController alloc] init];
    changeCtl.groupId = _group.groupId;
    changeCtl.oldTitle = _group.groupSubject;
    [self.navigationController pushViewController:changeCtl animated:YES];
}

- (IBAction)deleteMsg:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认删除聊天记录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:_group.groupId];

        }
    }];
}

- (IBAction)quitGroup:(UIButton *)sender {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    __weak ChatGroupSettingViewController *weakSelf = self;
    if ([_group.owner isEqualToString: accountManager.account.easemobUser]) {
        [self showHudInView:self.view hint:@"删除群组"];
        [[EaseMob sharedInstance].chatManager asyncDestroyGroup:_group.groupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
            [weakSelf hideHud];
            if (error) {
                [weakSelf showHint:@"删除群组失败"];
            }
            else{
                [weakSelf showHint:@"删除群组成功"];

            }
        } onQueue:nil];

    } else {
        [self showHudInView:self.view hint:@"退出群组"];
        [self sendMsgWhileQuit];
        [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_group.groupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
            [weakSelf hideHud];
            if (error) {
                [weakSelf showHint:@"退出群组失败"];
            }
            else{
                [weakSelf showHint:@"退出群组成功"];
            }
        } onQueue:nil];
        
    }
    
}

/**
 *  置顶聊天，但是暂时没有用到
 *
 *  @param sender
 */
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
