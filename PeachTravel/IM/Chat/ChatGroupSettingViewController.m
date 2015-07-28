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
#import "REFrostedViewController.h"

@interface ChatGroupSettingViewController () <UITableViewDataSource,UITableViewDelegate,CreateConversationDelegate,SWTableViewCellDelegate,changeTitle>

@property (nonatomic, strong) IMDiscussionGroup *groupModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatGroupSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    IMDiscussionGroupManager *groupManager = [IMDiscussionGroupManager shareInstance];
    _groupModel = [groupManager getFullDiscussionGroupInfoFromDBWithGroupId:_groupId];
    [self createTableView];
    [self updateGroupInfoFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"page_talk_setting"];
    [self updateView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [MobClick endLogPageView:@"page_talk_setting"];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (void)updateGroupInfoFromServer
{
    IMDiscussionGroupManager *groupManager = [IMDiscussionGroupManager shareInstance];
    [groupManager asyncGetDiscussionGroupInfoFromServer:_groupId completion:^(BOOL isSuccess, NSInteger errorCode, IMDiscussionGroup * group) {
        if (isSuccess) {
            [groupManager asyncGetMembersInDiscussionGroupInfoFromServer:group completion:^(BOOL isSuccess, NSInteger errorCode, IMDiscussionGroup * fullgroup) {
                if (isSuccess) {
                    _groupModel = fullgroup;
                } else {
                    _groupModel = group;
                }
                [self updateTableView];
            }];
        }
    }];
}

- (void)createTableView
{
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ChatGroupCell" bundle:nil] forCellReuseIdentifier:@"chatCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"AddMemberCell" bundle:nil] forCellReuseIdentifier:@"addCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ChatGroupSettingCell" bundle:nil] forCellReuseIdentifier:@"chatGroupSettingCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"UserOtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"otherCell"];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.tableFooterView = [self createFooterView];
    
}

- (UIView *)createFooterView
{
    UIView *footerBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 124)];
    footerBg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIButton *footerBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 32, CGRectGetWidth(self.view.bounds) - 20, 58 * SCREEN_HEIGHT/736)];
    [footerBtn setBackgroundImage:[[UIImage imageNamed:@"chat_drawer_leave.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    footerBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (_groupModel.owner == [AccountManager shareAccountManager].account.userId) {
        [footerBtn setTitle:@"解散该群" forState:UIControlStateNormal];
        [footerBtn addTarget:self action:@selector(quitGroup:) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        [footerBtn setTitle:@"退出该群" forState:UIControlStateNormal];
        [footerBtn addTarget:self action:@selector(deleteGroup:) forControlEvents:UIControlEventTouchUpInside];
    }
   

    [footerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    footerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [footerBg addSubview:footerBtn];
    return footerBg;
}

- (void)updateTableView
{
    _tableView.tableFooterView = [self createFooterView];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 64.0;
    } else {
        return 95.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView;
    if (section == 0) {
        CGFloat width = CGRectGetWidth(self.view.bounds);
        sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 64.0)];
        sectionHeaderView.backgroundColor = APP_PAGE_COLOR;
        sectionHeaderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        UIImageView *greenPointImageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 40, 10, 18)];
        greenPointImageView.image = [UIImage imageNamed:@"chat_drawer_poit"];
        greenPointImageView.contentMode = UIViewContentModeCenter;
        [sectionHeaderView addSubview:greenPointImageView];
        
        UILabel *strLabel = [[UILabel alloc]initWithFrame:CGRectMake(26, 40, 100, 18)];
        strLabel.font = [UIFont systemFontOfSize:13];
        strLabel.textColor = COLOR_TEXT_I;
        [sectionHeaderView addSubview:strLabel];
        strLabel.text = @"群设置";
    } else {
        CGFloat width = CGRectGetWidth(self.view.bounds);
        sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 95.0)];
        sectionHeaderView.backgroundColor = APP_PAGE_COLOR;
        sectionHeaderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        UIImageView *greenPointImageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 24.0, 10, 18)];
        greenPointImageView.image = [UIImage imageNamed:@"chat_drawer_poit"];
        greenPointImageView.contentMode = UIViewContentModeCenter;
        [sectionHeaderView addSubview:greenPointImageView];
        
        UILabel *strLabel = [[UILabel alloc]initWithFrame:CGRectMake(26, 24.0, 100, 18)];
        strLabel.font = [UIFont systemFontOfSize:13];
        strLabel.textColor = COLOR_TEXT_I;
        [sectionHeaderView addSubview:strLabel];
        strLabel.text = @"群成员";
        
        UIView *wp = [[UIView alloc] initWithFrame:CGRectMake(0, 48, width, 47)];
        wp.backgroundColor = [UIColor whiteColor];
        wp.layer.shadowColor = [UIColor blackColor].CGColor;
        wp.layer.shadowOffset = CGSizeMake(0.5, 0.5);
        wp.layer.shadowOpacity = 0.3;
        wp.layer.shadowRadius = 1.0;
        [sectionHeaderView addSubview:wp];
        
        UIButton *inviteBtn = [[UIButton alloc] initWithFrame:CGRectMake(13, 58, 48, 26)];
        inviteBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [inviteBtn setTitle:@"邀请" forState:UIControlStateNormal];
        [inviteBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [inviteBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
        inviteBtn.layer.cornerRadius = 4.0;
        inviteBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
        inviteBtn.layer.borderWidth = 1.0;
        [inviteBtn addTarget:self action:@selector(addGroupNumber:) forControlEvents:UIControlEventTouchUpInside];
       
        [sectionHeaderView addSubview:inviteBtn];
        
        UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(width - 48 - 15, 58, 48, 26)];
        editBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [editBtn setTitle:@"移除" forState:UIControlStateNormal];
        [editBtn setTitle:@"完成" forState:UIControlStateSelected];
        [editBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [editBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
        editBtn.layer.cornerRadius = 4.0;
        editBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
        editBtn.layer.borderWidth = 1.0;
        [editBtn addTarget:self action:@selector(editGroup:) forControlEvents:UIControlEventTouchUpInside];
        
        if (_groupModel.owner == [AccountManager shareAccountManager].account.userId) {
            [sectionHeaderView addSubview:editBtn];
        }
    }
    return sectionHeaderView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else  {
        return _groupModel.members.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 68 * SCREEN_HEIGHT / 736;
    } else {
        return 72 * SCREEN_HEIGHT / 736;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UserOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell" forIndexPath:indexPath];
            cell.cellTitle.text = @"群名称";
            cell.cellTitle.textColor = COLOR_TEXT_I;
            cell.cellTitle.font = [UIFont systemFontOfSize:15.0f];
            cell.cellDetail.text = _groupModel.subject;
            cell.cellDetail.font = [UIFont systemFontOfSize:16.0f];
            return cell;
        } else if (indexPath.row == 1) {
            ChatGroupSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatGroupSettingCell" forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabel.font = [UIFont systemFontOfSize:15.0];
            IMClientManager *clientManager = [IMClientManager shareInstance];
            ChatConversation *conversation = [clientManager.conversationManager getExistConversationInConversationList:_groupModel.groupId];
            [cell.switchBtn removeTarget:self action:@selector(changeMsgStatus:) forControlEvents:UIControlEventValueChanged];
            [cell.switchBtn addTarget:self action:@selector(changeMsgStatus:) forControlEvents:UIControlEventValueChanged];
            cell.switchBtn.on = [conversation isBlockMessage];
            cell.tag = 101;
            return cell;
        } else if (indexPath.row == 2) {
            UserOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell" forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.cellTitle.text = @"清空聊天记录";
            cell.cellTitle.font = [UIFont systemFontOfSize:15.0f];
            cell.cellTitle.textColor = COLOR_TEXT_I;
            cell.cellDetail.text = nil;
            return cell;
        }
    }
    
    else {
        ChatGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
        NSInteger i = indexPath.row;
        cell.nameLabel.text = ((FrendModel *)self.groupModel.members[i]).nickName;
        NSString *avatarStr = nil;
        if (![((FrendModel *)self.groupModel.members[i]).avatarSmall isBlankString]) {
            avatarStr = ((FrendModel *)self.groupModel.members[i]).avatarSmall;
        } else {
            avatarStr = ((FrendModel *)self.groupModel.members[i]).avatar;
        }
        [cell.headerImage sd_setImageWithURL:[NSURL URLWithString: avatarStr] placeholderImage:[UIImage imageNamed:@"ic_home_default_avatar.png"]];
        return cell;
    }
    ChatGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && ((FrendModel *)self.groupModel.members[indexPath.row]).userId != [AccountManager shareAccountManager].account.userId) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        IMDiscussionGroupManager *groupManager = [IMDiscussionGroupManager shareInstance];
        [groupManager asyncDeleteNumbersWithGroup:_groupModel members:@[_groupModel.members[indexPath.row]] completion:^(BOOL isSuccess, NSInteger errorCode) {
            if (isSuccess) {
                [SVProgressHUD showHint:@"删除成功"];
                [_tableView reloadData];
            } else {
                [SVProgressHUD showHint:@"删除失败"];
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
        } else if (indexPath.row == 2) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认清空全部聊天记录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:nil userInfo:nil];
                }
            }];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == _groupModel.members.count) {
            [self addGroupNumber:nil];
        } else {
            FrendModel *selectPerson = self.groupModel.members[indexPath.row ];
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
    NSInteger totalCtn = _groupModel.members.count;
    
    totalCtn++;
    int lineCnt = (int)totalCtn/4;
    if (totalCtn%4 != 0) {
        lineCnt++;
    }
    if (lineCnt == 0) {
        lineCnt = 1;
    }
    [_tableView reloadData];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.frostedViewController.panGestureEnabled = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.frostedViewController.panGestureEnabled = YES;
}

/**
 *  更新群组消息提醒状态，屏蔽和不屏蔽
 *
 *  @param sender
 */
- (IBAction)changeMsgStatus:(UISwitch *)sender {
    [[IMClientManager shareInstance].conversationManager asyncChangeConversationBlockStatusWithChatterId:_groupId isBlock:sender.isOn completion:^(BOOL isSuccess, NSInteger errorCode) {
        if (isSuccess) {
            NSLog(@"免打扰设置成功");
        } else {
            [SVProgressHUD showHint:@"设置失败"];
            [sender setOn:!sender.isOn animated:YES];
        }
    }];
}


/**
 *  解散该群
 *
 *  @param sender
 */
- (IBAction)quitGroup:(UIButton *)sender {
    
    IMDiscussionGroupManager * manager = [IMDiscussionGroupManager shareInstance];
    [manager asyncDeleteDiscussionGroup:_groupId completionBlock:^(BOOL isSuccess, NSInteger errorCode, NSDictionary * __nullable retMessage) {
        
        if (isSuccess) {
            NSLog(@"解散该群成功");
            IMClientManager *manager = [IMClientManager shareInstance];
            [manager.conversationManager removeConversationWithChatterId:_groupId deleteMessage:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSLog(@"解散失败");
        }
    }];
}

/**
 *  退出该群
 *
 *  @param sender
 */
- (IBAction)deleteGroup:(id)sender {
    
    IMDiscussionGroupManager *manager = [IMDiscussionGroupManager shareInstance];
    
    NSNumber * member = [NSNumber numberWithLong:[AccountManager shareAccountManager].account.userId];
    [manager asyncDeleteNumbersWithGroup:_groupModel members:@[member]
                              completion:^(BOOL isSuccess, NSInteger errorCode) {
                                  if (isSuccess) {
                                      NSLog(@"退出该群成功");
                                      IMClientManager * manager = [IMClientManager shareInstance];
                                      [manager.conversationManager removeConversationWithChatterId:_groupId deleteMessage:YES];
                                      [self.navigationController popViewControllerAnimated:YES];
                                  }
                              }];
}

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
