//
//  ChatSettingViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/5.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChatGroupSettingViewController.h"
#import "AccountManager.h"
#import "ChangeGroupTitleViewController.h"
#import "OtherUserInfoViewController.h"
#import "CreateConversationViewController.h"
#import "SearchUserInfoViewController.h"
#import "ChatGroupCell.h"
#import "AddMemberCell.h"
#import "SWTableViewCell.h"
#import "UserOtherTableViewCell.h"
#import "ChatGroupSettingCell.h"

@interface ChatGroupSettingViewController () <UITableViewDataSource,UITableViewDelegate,CreateConversationDelegate,SWTableViewCellDelegate,changeTitle>
{
    UIButton *_selectedBtn;
}

@property (nonatomic, strong) IMDiscussionGroup *groupModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatGroupSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createTableView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        IMDiscussionGroupManager *groupManager = [IMDiscussionGroupManager shareInstance];
        _groupModel = [groupManager getFullDiscussionGroupInfoFromDBWithGroupId:_groupId];
        dispatch_async(dispatch_get_main_queue(), ^{
           [_tableView reloadData];
        });
    });
    [self updateGroupInfoFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"page_talk_setting"];
    [self updateView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"page_talk_setting"];
}

- (void)updateGroupInfoFromServer
{
    IMDiscussionGroupManager *groupManager = [IMDiscussionGroupManager shareInstance];
    [groupManager asyncGetDiscussionGroupInfoFromServer:_groupId completion:^(BOOL isSuccess, NSInteger errorCode, IMDiscussionGroup * group) {
        if (isSuccess) {
            [groupManager asyncGetNumbersInDiscussionGroupInfoFromServer:group completion:^(BOOL isSuccess, NSInteger errorCode, IMDiscussionGroup * group) {
                if (isSuccess) {
                    _groupModel = group;
                    [_tableView reloadData];
                }
            }];
        }
    }];
}

- (void)createTableView
{
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.separatorColor = APP_DIVIDER_COLOR;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ChatGroupCell" bundle:nil] forCellReuseIdentifier:@"chatCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"AddMemberCell" bundle:nil] forCellReuseIdentifier:@"addCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ChatGroupSettingCell" bundle:nil] forCellReuseIdentifier:@"chatGroupSettingCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"UserOtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"otherCell"];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 64)];
    _tableView.tableFooterView = [self createFooterView];
    
}

- (UIView *)createFooterView
{
    UIView *footerBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 4.3/5, 338/3 * SCREEN_HEIGHT/736)];
    UIButton *footerBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 3.8/5, 177/3 * SCREEN_HEIGHT/736)];
    footerBtn.center = footerBg.center;
    footerBtn.backgroundColor = UIColorFromRGB(0xF75368);
    [footerBtn setTitle:@"退出聊天" forState:UIControlStateNormal];
    [footerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    footerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    footerBtn.layer.cornerRadius = 8;
    [footerBtn addTarget:self action:@selector(quitGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerBg addSubview:footerBtn];
    return footerBg;
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
        
    } else {
        return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
        sectionHeaderView.backgroundColor = APP_PAGE_COLOR;
        
        UIButton *addMemberBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, sectionHeaderView.bounds.size.width/2, 60)];
        [addMemberBtn setTitle:@"邀成朋友" forState:UIControlStateNormal];
        [addMemberBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        addMemberBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [addMemberBtn addTarget:self action:@selector(addGroupNumber:) forControlEvents:UIControlEventTouchUpInside];
        [sectionHeaderView addSubview:addMemberBtn];

        if (_groupModel.owner == [AccountManager shareAccountManager].account.userId) {
            UIButton *editGroup = [[UIButton alloc]initWithFrame:CGRectMake(sectionHeaderView.bounds.size.width/2+1, 0, sectionHeaderView.bounds.size.width/2-1, 60)];
            [editGroup setTitle:@"管理成员" forState:UIControlStateNormal];
            [editGroup setTitle:@"完成" forState:UIControlStateSelected];
            [editGroup setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
            editGroup.titleLabel.font = [UIFont systemFontOfSize:15];
            [editGroup addTarget:self action:@selector(editGroup:) forControlEvents:UIControlEventTouchUpInside];
            [sectionHeaderView addSubview:editGroup];
            
            UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, 60)];
            spaceView.backgroundColor = COLOR_LINE;
            [editGroup addSubview:spaceView];
        }
        return sectionHeaderView;
        
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else  {
        return _groupModel.numbers.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68 * SCREEN_HEIGHT / 736;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UserOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell" forIndexPath:indexPath];
            cell.cellTitle.text = @"群聊名称";
            cell.cellTitle.font = [UIFont systemFontOfSize:16];
            cell.cellDetail.text = _groupModel.subject;
            return cell;
            
        } else if (indexPath.row == 1) {
            ChatGroupSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatGroupSettingCell" forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            IMClientManager *clientManager = [IMClientManager shareInstance];
            
            ChatConversation *conversation = [clientManager.conversationManager getExistConversationInConversationList:_groupModel.groupId];
            [cell.switchBtn addTarget:self action:@selector(changeMsgStatus:) forControlEvents:UIControlEventValueChanged];
            cell.switchBtn.on = [conversation isBlockMessag];
            NSLog(@"cell.subviews.count: %ld", cell.subviews.count);
            cell.tag = 101;
            
            return cell;
            
        } else if (indexPath.row == 2) {
            UserOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell" forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.cellTitle.text = @"清记录";
            cell.cellTitle.font = [UIFont systemFontOfSize:16];
            cell.cellDetail.text = nil;
            return cell;
            
        }
    }
    
    else {
        ChatGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
        
        NSInteger i = indexPath.row ;
        
        cell.nameLabel.text = ((FrendModel *)self.groupModel.numbers[i]).nickName;
        NSString *avatarStr = nil;
        if (![((FrendModel *)self.groupModel.numbers[i]).avatarSmall isBlankString]) {
            avatarStr = ((FrendModel *)self.groupModel.numbers[i]).avatarSmall;
        } else {
            avatarStr = ((FrendModel *)self.groupModel.numbers[i]).avatar;
        }
        [cell.headerImage sd_setImageWithURL:[NSURL URLWithString: avatarStr] placeholderImage:[UIImage imageNamed:@"person_disabled"]];
        return cell;
    }
    ChatGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && ((FrendModel *)self.groupModel.numbers[indexPath.row]).userId != [AccountManager shareAccountManager].account.userId) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        IMDiscussionGroupManager *groupManager = [IMDiscussionGroupManager shareInstance];
        [groupManager asyncDeleteNumbersWithGroup:_groupModel numbers:@[_groupModel.numbers[indexPath.row]] completion:^(BOOL isSuccess, NSInteger errorCode) {
            if (isSuccess) {
                [SVProgressHUD showHint:@"删除成功"];
                [_tableView reloadData];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            ChangeGroupTitleViewController *changeCtl = [[ChangeGroupTitleViewController alloc] init];
            changeCtl.group = _groupModel;
            changeCtl.oldTitle = _groupModel.subject;
            changeCtl.delegate = self;
            [_containerCtl.navigationController pushViewController:changeCtl animated:YES];
            
        }
        else if (indexPath.row == 1) {
            [self changeMsgStatus:_selectedBtn];
            
        }
        
        else if (indexPath.row == 2) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认删除聊天记录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    
                    //                NSDictionary *group = [NSDictionary dictionary];
                    //                NSNumber *chatNum = [NSNumber numberWithInteger:_groupModel.groupId];
                    //                [group setValue:chatNum forKeyPath:@"groupId"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:nil userInfo:nil];
                }
            }];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == _groupModel.numbers.count) {
            [self addGroupNumber:nil];
        } else {
            FrendModel *selectPerson = self.groupModel.numbers[indexPath.row ];
            AccountManager *maneger = [AccountManager shareAccountManager];
            if (maneger.account.userId != selectPerson.userId) {
                [self  showUserInfoWithContactInfo:selectPerson];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"移除"];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 2)];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] attributedTitle:attr];
    return rightUtilityButtons;
}

- (void)updateView
{
    CGFloat contactViewHight = 0;
    NSInteger totalCtn = _groupModel.numbers.count;

    totalCtn++;
    int lineCnt = (int)totalCtn/4;
    if (totalCtn%4 != 0) {
        lineCnt++;
    }
    if (lineCnt == 0) {
        lineCnt = 1;
    }
    contactViewHight = 10 + 90*lineCnt;
    
    [_tableView reloadData];
//    [self createContactsScrollView];
}

//增加群组成员
- (IBAction)addGroupNumber:(id)sender
{
    CreateConversationViewController *createConversationCtl = [[CreateConversationViewController alloc] init];
    createConversationCtl.group = _groupModel;
    [_containerCtl.navigationController pushViewController:createConversationCtl animated:YES];
}

- (IBAction)editGroup:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [_tableView setEditing:sender.selected animated:YES];
}

/**
 *  删除群组里的用户
 *
 *  @param sender
 */
- (IBAction)deleteNumber:(UIButton *)sender
{
}

/**
 *  点击群组联系人列表的头像进入联系人信息
 *
 *  @param sender
 */
- (IBAction)showUserInfo:(UIButton *)sender
{

}

- (void)showUserInfoWithContactInfo:(FrendModel *)contact
{
    OtherUserInfoViewController *contactDetailCtl = [[OtherUserInfoViewController alloc]init];
    contactDetailCtl.userId = contact.userId;
    [self.navigationController pushViewController:contactDetailCtl animated:YES];
}



/**
 *  当退出一个群组，向群里发送一条退出语句
 */
/*
 - (void)sendMsgWhileQuit
 {
 AccountManager *accountManager = [AccountManager shareAccountManager];
 NSString *messageStr = [NSString stringWithFormat:@"%@退出了群组",accountManager.account.nickName];
 
 NSDictionary *messageDic = @{@"tzType":[NSNumber numberWithInt:TZTipsMsg], @"content":messageStr};
 
 [ChatSendHelper sendTaoziMessageWithString:messageStr andExtMessage:messageDic toUsername:_group.groupId isChatGroup:YES requireEncryption:NO];
 }
 */

/**
 *  更新群组消息提醒状态，屏蔽和不屏蔽
 *
 *  @param sender
 */
- (IBAction)changeMsgStatus:(UIButton *)sender {
    IMDiscussionGroupManager *manager = [IMDiscussionGroupManager shareInstance];
    [manager asyncChangeDiscussionGroupStateWithGroup:_groupModel completion:^(BOOL isSuccess, NSInteger errorCode) {
        if (isSuccess) {
            
        }
    }];

}

- (IBAction)changeGroupTitle:(UIButton *)sender {
}

- (IBAction)deleteMsg:(UIButton *)sender {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认删除聊天记录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
//        if (buttonIndex == 1) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:_groupModel.groupId];
//            
//        }
//    }];
}

- (IBAction)quitGroup:(UIButton *)sender {
//    AccountManager *accountManager = [AccountManager shareAccountManager];
//    __weak ChatGroupSettingViewController *weakSelf = self;
//    if ([_group.owner isEqualToString: accountManager.account.easemobUser]) {
//        [self showHudInView:self.view hint:@"删除群组"];
//        [[EaseMob sharedInstance].chatManager asyncDestroyGroup:_group.groupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
//            [weakSelf hideHud];
//            if (error) {
//                [weakSelf showHint:@"删除群组失败"];
//            }
//            else{
//                [weakSelf showHint:@"删除群组成功"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
//                
//            }
//        } onQueue:nil];
//        
//    } else {
//        [self showHudInView:self.view hint:@"退出群组"];
//        [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_group.groupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
//            [weakSelf hideHud];
//            if (error) {
//                [weakSelf showHint:@"退出群组失败"];
//            }
//            else{
//                [weakSelf showHint:@"退出群组成功"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
//            }
//        } onQueue:nil];
//        
//    }
    
}
//-(void)viewWillDisappear:(BOOL)animated
//{
//    self.navigationController.navigationBarHidden = NO;
//}
/**
 *  置顶聊天，但是暂时没有用到
 *
 *  @param sender
 */
- (IBAction)upChatList:(UIButton *)sender {
}

#pragma mark - CreateConversationDelegate
- (void)reloadData
{
    [self updateView];
}

#pragma mark - changeTitle
- (void)changeTitleDelegate
{
    [self updateView];
}
@end
