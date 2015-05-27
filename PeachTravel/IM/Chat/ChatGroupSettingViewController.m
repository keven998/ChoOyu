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
#import "Group.h"
#import "ContactDetailViewController.h"
#import "OtherUserInfoViewController.h"
#import "CreateConversationViewController.h"
#import "SearchUserInfoViewController.h"
#import "ChatGroupCell.h"
#import "AddMemberCell.h"
#import "SWTableViewCell.h"
@interface ChatGroupSettingViewController () <IChatManagerDelegate,UITableViewDataSource,UITableViewDelegate,CreateConversationDelegate,SWTableViewCellDelegate>
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
        _groupModel = [groupManager getFullDiscussionGroupInfoWithGroupId:_groupId];
       dispatch_async(dispatch_get_main_queue(), ^{
           [_tableView reloadData];
       });
    });
   }

-(void)createTableView
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
-(void)createFooterView
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
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        cell.textLabel.text = _groupModel.subject;
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
//        _selectedBtn.selected = !_group.isPushNotificationEnabled;
        [cell addSubview:_selectedBtn];
        cell.textLabel.text = @"免打扰";
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
        return cell;
        
    } else if (indexPath.row == 3) {
        AddMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addCell" forIndexPath:indexPath];
        
        return cell;
        
    } else if(indexPath.row >3&&indexPath.row < _groupModel.numbers.count+4) {
        ChatGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
        cell.delegate = self;
        NSInteger i = indexPath.row - 4;
        cell.nameLabel.text = ((Contact *)self.groupModel.numbers[i]).nickName;
        [cell.headerImage sd_setImageWithURL:[NSURL URLWithString:((Contact *)self.groupModel.numbers[i]).avatarSmall] placeholderImage:[UIImage imageNamed:@"person_disabled"]];
        return cell;
    }
    return 0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
//        if ([_group.owner isEqualToString: [AccountManager shareAccountManager].account.easemobUser]) {
//            ChangeGroupTitleViewController *changeCtl = [[ChangeGroupTitleViewController alloc] init];
//            changeCtl.groupId = _group.groupId;
//            changeCtl.oldTitle = _group.groupSubject;
//            [self.navigationController pushViewController:changeCtl animated:YES];
//        } else {
//            [SVProgressHUD showHint:@"不是群主，无法修改"];
//        }
    }
    else if (indexPath.row == 1) {
        
        [self changeMsgStatus:_selectedBtn];
        
    }
    
    else if (indexPath.row == 2) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认删除聊天记录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:_groupModel.groupId];
            }
        }];
    }
    
    else if (indexPath.row == 3) {
        [self addGroupNumber:nil];
        
    }else if (indexPath.row >3 && indexPath.row < _groupModel.numbers.count +4) {
        Contact *selectPerson = self.groupModel.numbers[indexPath.row - 4];
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

/**
 *  如果是群组的话，点击展开按钮，返回所有的联系人信息
 *
 *  @return 所有的聊天人的信息
 */
- (NSArray *)createContactsScrollView
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!_numberBtns) {
        _numberBtns = [[NSMutableArray alloc] init];
    }
    if (!_numberDeleteBtns) {
        _numberDeleteBtns = [[NSMutableArray alloc] init];
    }
    [self.numberBtns removeAllObjects];
    [self.numberDeleteBtns removeAllObjects];
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    
    CGFloat spaceWidth = (kWindowWidth-40-60*4)/3;
    CGFloat offsetY = 20;
    int j = 0;
    for (int i = 0; i < self.groupModel.numbers.count; i++) {
        
        FrendModel *contact = self.groupModel.numbers[i];
        if (accountManager.account.userId.integerValue != contact.userId) {
            int index = j%4;
            if (index == 0 && j != 0) {
                offsetY += 90;
            }
            
            UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(20+(spaceWidth+60)*index, offsetY, 60, 60)];
            item.layer.cornerRadius = 5;
            item.tag = i;
            [item sd_setBackgroundImageWithURL:[NSURL URLWithString:((Contact *)self.groupModel.numbers[i]).avatarSmall] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"person_disabled"]];
            item.clipsToBounds = YES;
            [item addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+(spaceWidth+60)*index, offsetY+65, 60, 15)];
            nickNameLabel.text = contact.nickName;
            nickNameLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
            nickNameLabel.textAlignment = NSTextAlignmentCenter;
            nickNameLabel.font = [UIFont systemFontOfSize:13.0];
            [_contactsView addSubview:nickNameLabel];
            
            UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [deleteBtn setImage:[UIImage imageNamed:@"ic_remove_select_one.png"] forState:UIControlStateNormal];
            [deleteBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 20, 20)];
            deleteBtn.tag = i;
            [deleteBtn addTarget:self action:@selector(deleteNumber:) forControlEvents:UIControlEventTouchUpInside];
            deleteBtn.hidden = YES;
            [item addSubview:deleteBtn];
            [retArray addObject:item];
            [self.numberBtns addObject:item];
            [self.numberDeleteBtns addObject:deleteBtn];
            [titles addObject:((Contact *)self.groupModel.numbers[i]).nickName];
            [_contactsView addSubview:item];
            j++;
        }
    }
    int index = j%4;
    if (index == 0 && j != 0) {
        offsetY += 90;
    }
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(20+(spaceWidth+60)*index, offsetY, 60, 60)];
    [addBtn addTarget:self action:@selector(addGroupNumber:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setImage:[UIImage imageNamed:@"add_contact.png"] forState:UIControlStateNormal];
    [_contactsView addSubview:addBtn];
    j++;
    index = j%4;
    if (index == 0 && j != 0) {
        offsetY += 90;
    }
    
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(20+(spaceWidth+60)*index, offsetY, 60, 60)];
    [deleteBtn addTarget:self action:@selector(willDeleteNumber:) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn setImage:[UIImage imageNamed:@"delete_contact.png"] forState:UIControlStateNormal];
    [_contactsView addSubview:deleteBtn];
    return retArray;
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

- (void)showUserInfoWithContactInfo:(Contact *)contact
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    if ([accountManager isMyFrend:contact.userId]) {
//        ContactDetailViewController *contactDetailCtl = [[ContactDetailViewController alloc] init];
        OtherUserInfoViewController *contactDetailCtl = [[OtherUserInfoViewController alloc]init];
        contactDetailCtl.userId = contact.userId;
//        contactDetailCtl.goBackToChatViewWhenClickTalk = NO;
        [self.navigationController pushViewController:contactDetailCtl animated:YES];
        
    } else {
//        SearchUserInfoViewController *searchUserInfoCtl = [[SearchUserInfoViewController alloc] init];
//        searchUserInfoCtl.userInfo = @{@"userId":contact.userId,
//                                       @"avatar":contact.avatar,
//                                       @"nickName":contact.nickName,
//                                       @"signature":contact.signature,
//                                       @"easemobUser":contact.easemobUser
//                                       };
        OtherUserInfoViewController *searchUserInfoCtl = [[OtherUserInfoViewController alloc]init];
        searchUserInfoCtl.userId = contact.userId;
        [self.navigationController pushViewController:searchUserInfoCtl animated:YES];
    }
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
//    [cell hideUtilityButtonsAnimated:YES];
//    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
//    
//    Contact *selectPerson = _groupNumbers[indexPath.row-4];
//    AccountManager *accountManager = [AccountManager shareAccountManager];
//    
//    NSArray *occupants = @[selectPerson.easemobUser];
//    __weak typeof(self)weakSelf = self;
//    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
//    [hud showHUDInViewController:weakSelf];
//    
//    [[EaseMob sharedInstance].chatManager asyncRemoveOccupants:occupants fromGroup:self.group.groupId completion:^(EMGroup *group, EMError *error) {
//        [hud hideTZHUD];
//        if (!error) {
//            [accountManager removeNumberToGroup:self.group.groupId numbers:[NSSet setWithObject:selectPerson]];
//            self.groupNumbers = [self loadGroupNumbers];
//            [self updateView];
//            for (UIButton *btn in self.numberDeleteBtns) {
//                btn.hidden = NO;
//            }
////            AccountManager *accountManager = [AccountManager shareAccountManager];
////            NSString *messageStr = [NSString stringWithFormat:@"%@把%@移除了群组",accountManager.account.nickName, selectPerson.nickName];
////            
////            NSDictionary *messageDic = @{@"tzType":[NSNumber numberWithInt:TZTipsMsg], @"content":messageStr};
////            
////            EMMessage *message = [ChatSendHelper sendTaoziMessageWithString:messageStr andExtMessage:messageDic toUsername:self.group.groupId isChatGroup:YES requireEncryption:NO];
////            [[NSNotificationCenter defaultCenter] postNotificationName:updateChateViewNoti object:nil userInfo:@{@"message":message}];
//            
//        } else {
//        }
//    } onQueue:nil];

}
#pragma mark - CreateConversationDelegate
-(void)reloadData
{
    [self updateView];
}

@end
