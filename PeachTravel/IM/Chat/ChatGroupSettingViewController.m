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

@interface ChatGroupSettingViewController () <UITableViewDataSource,UITableViewDelegate,CreateConversationDelegate,SWTableViewCellDelegate,changeTitle>
{
    UITableView *_tableView;
    UIButton *_selectedBtn;
}
@property (weak, nonatomic) IBOutlet UIView *contactsView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *disturbBtn;
@property (weak, nonatomic) IBOutlet UIButton *groupTitle;
@property (weak, nonatomic) IBOutlet UIButton *quitBtn;
@property (nonatomic, strong) IMDiscussionGroup *groupModel;

@property (strong, nonatomic) NSMutableArray *numberBtns;   //群组的时候存放群组头像的 btn
@property (strong, nonatomic) NSMutableArray *numberDeleteBtns; //群组的时候存放群组头像上的删除按钮的 btn

/**
 *
 */
//@property (weak, nonatomic) IBOutlet UIImageView *groupMsgStatusImageView;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;

//@property (nonatomic) BOOL isPushNotificationEnable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsViewHight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceHight;

@end

@implementation ChatGroupSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
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
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorColor = APP_DIVIDER_COLOR;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ChatGroupCell" bundle:nil] forCellReuseIdentifier:@"chatCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"AddMemberCell" bundle:nil] forCellReuseIdentifier:@"addCell"];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    _tableView.tableHeaderView = headerView;
    [self createFooterView];
    
    [self.view addSubview:_tableView];
    
}
- (void)createFooterView
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*4/5, 50)];
    footerView.backgroundColor = [UIColor whiteColor];
    UIButton *footerBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
//    AccountManager *accountManager = [AccountManager shareAccountManager];
//    if ([_group.owner isEqualToString: accountManager.account.easemobUser]) {
        [footerBtn setTitle:@"解散该群" forState:UIControlStateNormal];
//    } else {
//        [footerBtn setTitle:@"退出该群" forState:UIControlStateNormal];
//    }
    [footerBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    footerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    footerBtn.layer.borderWidth = 1;
    footerBtn.layer.cornerRadius = 8;
    footerBtn.center = footerView.center;
    [footerView addSubview:footerBtn];
    [footerBtn addTarget:self action:@selector(quitGroup:) forControlEvents:UIControlEventTouchUpInside];
    _tableView.tableFooterView = footerView;
    
}
#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groupModel.numbers.count + 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 49;
    }else if (indexPath.row == 3){
        return 65;
    }
    return 49;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.text = _groupModel.subject;
        cell.imageView.image = [UIImage imageNamed:@"ic_chat_ce_groupsetting"];
        UIView *divide = [[UIView alloc]initWithFrame:CGRectMake(18, 48, SCREEN_WIDTH, 1)];
        divide.backgroundColor = APP_DIVIDER_COLOR;
        [cell addSubview:divide];
        return cell;
        
    } else if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        _selectedBtn = [[UIButton alloc]initWithFrame:CGRectMake(374/2, 29/2, 20, 20)];
        [_selectedBtn setImage:[UIImage imageNamed:@"ic_button_normal"] forState:UIControlStateNormal];
        [_selectedBtn addTarget:self action:@selector(changeMsgStatus:) forControlEvents:UIControlEventTouchUpInside];
        [_selectedBtn setImage:[UIImage imageNamed:@"ic_button_selected"] forState:UIControlStateSelected];
        
        IMClientManager *clientManager = [IMClientManager shareInstance];
        
        ChatConversation *conversation = [clientManager.conversationManager getExistConversationInConversationList:_groupModel.groupId];
        _selectedBtn.selected = [conversation isBlockMessag];
        [cell addSubview:_selectedBtn];
        cell.textLabel.text = @"免打扰";
        cell.imageView.image = [UIImage imageNamed:@"ic_chat_ce_wurao"];
        cell.tag = 101;
        UIView *divide = [[UIView alloc]initWithFrame:CGRectMake(18, 48, SCREEN_WIDTH, 1)];
        divide.backgroundColor = APP_DIVIDER_COLOR;
        [cell addSubview:divide];
        
        return cell;
        
    } else if (indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        UIView *divide = [[UIView alloc]initWithFrame:CGRectMake(18, 48, SCREEN_WIDTH, 1)];
        divide.backgroundColor = APP_DIVIDER_COLOR;
        [cell addSubview:divide];
        cell.textLabel.text = @"清空聊天记录";
        cell.imageView.image = [UIImage imageNamed:@"ic_chat_ce_rubbish"];
        return cell;
        
    } else if (indexPath.row == 3) {
        AddMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addCell" forIndexPath:indexPath];
        
        return cell;
        
    } else {
        ChatGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
        cell.delegate = self;
        NSInteger i = indexPath.row - 4;
        
        NSLog(@"%@", ((FrendModel *)self.groupModel.numbers[i]).avatar);
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ChangeGroupTitleViewController *changeCtl = [[ChangeGroupTitleViewController alloc] init];
        changeCtl.group = _groupModel;
        changeCtl.oldTitle = _groupModel.subject;
        changeCtl.delegate = self;
        [self.navigationController pushViewController:changeCtl animated:YES];
    
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
    
    else if (indexPath.row == 3) {
        [self addGroupNumber:nil];
        
    }else if (indexPath.row >3 && indexPath.row < _groupModel.numbers.count +4) {
        FrendModel *selectPerson = self.groupModel.numbers[indexPath.row - 4];
        [self  showUserInfoWithContactInfo:selectPerson];
        
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_talk_setting"];
    [self updateView];
   
    //    [_groupTitle setTitle:_group.groupSubject forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    self.navigationController.navigationBarHidden = NO;
    [MobClick endLogPageView:@"page_talk_setting"];
}
-(void)viewDidDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
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
    _contactsViewHight.constant = contactViewHight+20;
    
    for (UIView *view in _contactsView.subviews) {
        [view removeFromSuperview];
    }
    [_tableView reloadData];
    //    [self createContactsScrollView];
}

- (IBAction)willDeleteNumber:(id)sender
{
    for (UIButton *deleteBtn in _numberDeleteBtns) {
        deleteBtn.hidden = !deleteBtn.hidden;
    }
}

//增加群组成员
- (IBAction)addGroupNumber:(id)sender
{
    CreateConversationViewController *createConversationCtl = [[CreateConversationViewController alloc] init];
    createConversationCtl.group = _groupModel;
    TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:createConversationCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
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
            _selectedBtn.selected = !_selectedBtn.selected;
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

#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    IMDiscussionGroupManager *groupManager = [IMDiscussionGroupManager shareInstance];
    
    [groupManager asyncDeleteNumbersWithGroup:_groupModel numbers:@[_groupModel.numbers[index]] completion:^(BOOL isSuccess, NSInteger errorCode) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"删除成功"];
            [_tableView reloadData];
        }
    }];
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
