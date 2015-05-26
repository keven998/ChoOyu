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
@property (nonatomic, strong) NSArray *groupNumbers;

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
    
    /*
     [_groupTitle setTitle:_group.groupSubject forState:UIControlStateNormal];
     _groupTitle.titleEdgeInsets = UIEdgeInsetsMake(0, 88, 0, 20);
     AccountManager *accountManager = [AccountManager shareAccountManager];
     
     //只有管理员可以修改群组名称
     if ([_group.owner isEqualToString: accountManager.account.easemobUser]) {
     _groupTitle.userInteractionEnabled = YES;
     [_quitBtn setTitle:@"解散该群" forState:UIControlStateNormal];
     } else {
     _groupTitle.userInteractionEnabled = YES;
     _accessoryImageView.hidden = YES;
     [_quitBtn setTitle:@"退出该群" forState:UIControlStateNormal];
     }
     
     _quitBtn.layer.cornerRadius = 2.0;
     [_quitBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
     _quitBtn.clipsToBounds = YES;
     
     _disturbBtn.selected = !_group.isPushNotificationEnabled;
     */
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [self asyncLoadGroupFromEasemobServerWithCompletion:^(BOOL isSuccess) {
        [self updateView];
    }];
    
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
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([_group.owner isEqualToString: accountManager.account.easemobUser]) {
        [footerBtn setTitle:@"解散该群" forState:UIControlStateNormal];
    } else {
        [footerBtn setTitle:@"退出该群" forState:UIControlStateNormal];
    }
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
    return _groupNumbers.count + 4;
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
        
        cell.textLabel.text = _group.groupSubject;
        UIView *divide = [[UIView alloc]initWithFrame:CGRectMake(18, 48, SCREEN_WIDTH, 1)];
        divide.backgroundColor = APP_DIVIDER_COLOR;
        [cell addSubview:divide];
        return cell;
    }else if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        _selectedBtn = [[UIButton alloc]initWithFrame:CGRectMake(374/2, 29/2, 20, 20)];
        [_selectedBtn setImage:[UIImage imageNamed:@"ic_button_normal"] forState:UIControlStateNormal];
        [_selectedBtn addTarget:self action:@selector(changeMsgStatus:) forControlEvents:UIControlEventTouchUpInside];
        [_selectedBtn setImage:[UIImage imageNamed:@"ic_button_selected"] forState:UIControlStateSelected];
        _selectedBtn.selected = !_group.isPushNotificationEnabled;
        [cell addSubview:_selectedBtn];
        cell.textLabel.text = @"免打扰";
        cell.tag = 101;
        UIView *divide = [[UIView alloc]initWithFrame:CGRectMake(18, 48, SCREEN_WIDTH, 1)];
        divide.backgroundColor = APP_DIVIDER_COLOR;
        [cell addSubview:divide];
        
        return cell;
    }else if (indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        UIView *divide = [[UIView alloc]initWithFrame:CGRectMake(18, 48, SCREEN_WIDTH, 1)];
        divide.backgroundColor = APP_DIVIDER_COLOR;
        [cell addSubview:divide];
        cell.textLabel.text = @"清空聊天记录";
        return cell;
    }
    else if (indexPath.row == 3) {
        AddMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addCell" forIndexPath:indexPath];
        
        return cell;
    }
    else if(indexPath.row >3&&indexPath.row < _groupNumbers.count+4) {
        ChatGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
        cell.delegate = self;
        NSInteger i = indexPath.row - 4;
        cell.nameLabel.text = ((Contact *)self.groupNumbers[i]).nickName;
        [cell.headerImage sd_setImageWithURL:[NSURL URLWithString:((Contact *)self.groupNumbers[i]).avatarSmall] placeholderImage:[UIImage imageNamed:@"person_disabled"]];
        return cell;
    }
    return 0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if ([_group.owner isEqualToString: [AccountManager shareAccountManager].account.easemobUser]) {
            ChangeGroupTitleViewController *changeCtl = [[ChangeGroupTitleViewController alloc] init];
            changeCtl.groupId = _group.groupId;
            changeCtl.oldTitle = _group.groupSubject;
            [self.navigationController pushViewController:changeCtl animated:YES];
        } else {
            [SVProgressHUD showHint:@"不是群主，无法修改"];
        }
    }
    else if (indexPath.row == 1) {
        
        [self changeMsgStatus:_selectedBtn];
        
    }
    
    else if (indexPath.row == 2) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认删除聊天记录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:_group.groupId];
            }
        }];
    }
    
    else if (indexPath.row == 3) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        CreateConversationViewController *createConversationCtl = [[CreateConversationViewController alloc] init];
        createConversationCtl.emGroup = _group;
        createConversationCtl.group = [accountManager groupWithGroupId:_group.groupId];
        createConversationCtl.delegate = self;
        TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:createConversationCtl];
        [self presentViewController:nCtl animated:YES completion:nil];
        
    }else if (indexPath.row >3 && indexPath.row < _groupNumbers.count +4) {
        Contact *selectPerson = self.groupNumbers[indexPath.row - 4];
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
    for (EMGroup *tempGroup in [[EaseMob sharedInstance].chatManager groupList]) {
        if ([_group.groupId isEqualToString:tempGroup.groupId]) {
            _group = tempGroup;
            break;
        }
    }
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

- (NSArray *)loadGroupNumbers
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    Group *tzGroup = [accountManager groupWithGroupId:_group.groupId];
    if (tzGroup) {
        for (id item in tzGroup.numbers) {
            [contacts addObject:item];
        }
    }
    [contacts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return ((Contact *)obj1).userId >  ((Contact *)obj2).userId;
    }];
    return contacts;
    
}

/**
 *  异步从环信服务器上取群组的信息
 */
- (void)asyncLoadGroupFromEasemobServerWithCompletion:(void(^)(BOOL isSuccess))completion
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:_group.groupId completion:^(EMGroup *group, EMError *error){
        if (!error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self loadContactsFromTZServerWithGroup:group withCompletion:completion];
        }
    } onQueue:nil];
}

- (void)loadContactsFromTZServerWithGroup:(EMGroup *)emgroup withCompletion:(void(^)(BOOL))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", [AccountManager shareAccountManager].account.userId] forHTTPHeaderField:@"UserId"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:emgroup.occupants forKey:@"easemob"];
    
    NSLog(@"---%@",emgroup.occupants);
    //获取用户信息列表
    [manager POST:API_GET_USERINFO_WITHEASEMOB parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self updateGroupInDB:[responseObject objectForKey:@"result"] andEMGroup:emgroup];
            completion(YES);
        } else {
            completion(NO);
            [self showHint:@"呃～好像没找到网络"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        completion(NO);
        [self showHint:@"呃～好像没找到网络"];
    }];
    
}

- (void)updateGroupInDB:(id)numbersDic andEMGroup:(EMGroup *)emGroup
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [accountManager updateGroup:emGroup.groupId withGroupOwner:emGroup.owner groupSubject:emGroup.groupSubject groupInfo:emGroup.groupDescription numbers:numbersDic];
}

- (void)updateView
{
    _groupNumbers = [self loadGroupNumbers];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    CGFloat contactViewHight = 0;
    NSInteger totalCtn = _groupNumbers.count;
    if ([accountManager.account.easemobUser isEqualToString:self.group.owner]) {
        totalCtn++;
    }
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
    for (int i = 0; i < self.groupNumbers.count; i++) {
        
        Contact *contact = self.groupNumbers[i];
        if (accountManager.account.userId.integerValue != contact.userId.integerValue) {
            int index = j%4;
            if (index == 0 && j != 0) {
                offsetY += 90;
            }
            
            UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(20+(spaceWidth+60)*index, offsetY, 60, 60)];
            item.layer.cornerRadius = 5;
            item.tag = i;
            [item sd_setBackgroundImageWithURL:[NSURL URLWithString:((Contact *)self.groupNumbers[i]).avatarSmall] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"person_disabled"]];
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
            [titles addObject:((Contact *)self.groupNumbers[i]).nickName];
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
    
    if ([_group.owner isEqualToString: accountManager.account.easemobUser]) {
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(20+(spaceWidth+60)*index, offsetY, 60, 60)];
        [deleteBtn addTarget:self action:@selector(willDeleteNumber:) forControlEvents:UIControlEventTouchUpInside];
        [deleteBtn setImage:[UIImage imageNamed:@"delete_contact.png"] forState:UIControlStateNormal];
        [_contactsView addSubview:deleteBtn];
    }
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
    AccountManager *accountManager = [AccountManager shareAccountManager];
    CreateConversationViewController *createConversationCtl = [[CreateConversationViewController alloc] init];
    createConversationCtl.emGroup = _group;
    createConversationCtl.group = [accountManager groupWithGroupId:_group.groupId];
    
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
    Contact *selectPerson = self.groupNumbers[sender.tag];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    NSArray *occupants = @[selectPerson.easemobUser];
    __weak typeof(self)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [[EaseMob sharedInstance].chatManager asyncRemoveOccupants:occupants fromGroup:self.group.groupId completion:^(EMGroup *group, EMError *error) {
        [hud hideTZHUD];
        if (!error) {
            [accountManager removeNumberToGroup:self.group.groupId numbers:[NSSet setWithObject:selectPerson]];
            self.groupNumbers = [self loadGroupNumbers];
            [self updateView];
            for (UIButton *btn in self.numberDeleteBtns) {
                btn.hidden = NO;
            }
            AccountManager *accountManager = [AccountManager shareAccountManager];
            NSString *messageStr = [NSString stringWithFormat:@"%@把%@移除了群组",accountManager.account.nickName, selectPerson.nickName];
            
            NSDictionary *messageDic = @{@"tzType":[NSNumber numberWithInt:TZTipsMsg], @"content":messageStr};
            
            EMMessage *message = [ChatSendHelper sendTaoziMessageWithString:messageStr andExtMessage:messageDic toUsername:self.group.groupId isChatGroup:YES requireEncryption:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:updateChateViewNoti object:nil userInfo:@{@"message":message}];
            
        } else {
        }
    } onQueue:nil];
}

/**
 *  点击群组联系人列表的头像进入联系人信息
 *
 *  @param sender
 */
- (IBAction)showUserInfo:(UIButton *)sender
{
    Contact *selectPerson = self.groupNumbers[sender.tag];
    [self  showUserInfoWithContactInfo:selectPerson];
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
        SearchUserInfoViewController *searchUserInfoCtl = [[SearchUserInfoViewController alloc] init];
        searchUserInfoCtl.userInfo = @{@"userId":contact.userId,
                                       @"avatar":contact.avatar,
                                       @"nickName":contact.nickName,
                                       @"signature":contact.signature,
                                       @"easemobUser":contact.easemobUser
                                       };
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
    __weak ChatGroupSettingViewController *weakSelf = self;
    //    sender.userInteractionEnabled = NO;
    [self showHudInView:self.view hint:@"正在设置"];
    sender.selected = !sender.selected;
    [[EaseMob sharedInstance].chatManager asyncIgnoreGroupPushNotification:_group.groupId isIgnore:sender.selected completion:^(NSArray *ignoreGroupsList, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            [weakSelf showHint:@"设置成功"];
        } else {
            [weakSelf showHint:@"设置失败"];
            sender.selected = !sender.selected;
        }
        //        sender.userInteractionEnabled = YES;
    } onQueue:nil];
    
}

- (IBAction)changeGroupTitle:(UIButton *)sender {
    if ([_group.owner isEqualToString: [AccountManager shareAccountManager].account.easemobUser]) {
        ChangeGroupTitleViewController *changeCtl = [[ChangeGroupTitleViewController alloc] init];
        changeCtl.groupId = _group.groupId;
        changeCtl.oldTitle = _group.groupSubject;
        [self.navigationController pushViewController:changeCtl animated:YES];
    } else {
        [SVProgressHUD showHint:@"不是群主，无法修改"];
    }
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
                
            }
        } onQueue:nil];
        
    } else {
        [self showHudInView:self.view hint:@"退出群组"];
        [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_group.groupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
            [weakSelf hideHud];
            if (error) {
                [weakSelf showHint:@"退出群组失败"];
            }
            else{
                [weakSelf showHint:@"退出群组成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
            }
        } onQueue:nil];
        
    }
    
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
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    Contact *selectPerson = _groupNumbers[indexPath.row-4];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    NSArray *occupants = @[selectPerson.easemobUser];
    __weak typeof(self)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [[EaseMob sharedInstance].chatManager asyncRemoveOccupants:occupants fromGroup:self.group.groupId completion:^(EMGroup *group, EMError *error) {
        [hud hideTZHUD];
        if (!error) {
            [accountManager removeNumberToGroup:self.group.groupId numbers:[NSSet setWithObject:selectPerson]];
            self.groupNumbers = [self loadGroupNumbers];
            [self updateView];
            for (UIButton *btn in self.numberDeleteBtns) {
                btn.hidden = NO;
            }
            AccountManager *accountManager = [AccountManager shareAccountManager];
            NSString *messageStr = [NSString stringWithFormat:@"%@把%@移除了群组",accountManager.account.nickName, selectPerson.nickName];
            
            NSDictionary *messageDic = @{@"tzType":[NSNumber numberWithInt:TZTipsMsg], @"content":messageStr};
            
            EMMessage *message = [ChatSendHelper sendTaoziMessageWithString:messageStr andExtMessage:messageDic toUsername:self.group.groupId isChatGroup:YES requireEncryption:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:updateChateViewNoti object:nil userInfo:@{@"message":message}];
            
        } else {
        }
    } onQueue:nil];

}
#pragma mark - CreateConversationDelegate
-(void)reloadData
{
    [self updateView];
}

@end
