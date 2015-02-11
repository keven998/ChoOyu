//
//  CreateCoversationViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "CreateConversationViewController.h"
#import "pinyin.h"
#import "AccountManager.h"
#import "ChatView/ChatViewController.h"
#import "CreateConversationTableViewCell.h"
#import "ChatView/ChatSendHelper.h"
#import "SelectContactScrollView.h"
#import "SelectContactUnitView.h"
#import "MJNIndexView.h"

#define contactCell      @"createConversationCell"

@interface CreateConversationViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, TaoziSelectViewDelegate, MJNIndexViewDataSource>

@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) SelectContactScrollView *selectContactView;

//索引
@property (nonatomic, strong) MJNIndexView *indexView;

@end

@implementation CreateConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.title = @"选择";
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.selectContactView];
    [self.view addSubview:self.contactTableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc]initWithTitle:@"确定 " style:UIBarButtonItemStyleBordered target:self action:@selector(createConversation:)];
    confirm.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = confirm;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (!_isPushed) {
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@" 取消" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissCtl:)];
        backBtn.tintColor = TEXT_COLOR_TITLE_SUBTITLE;
        self.navigationItem.leftBarButtonItem = backBtn;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissCtl:) name:userDidLogoutNoti object:nil];
    }
    
    self.indexView = [[MJNIndexView alloc] initWithFrame:self.view.bounds];
    self.indexView.rightMargin = 0;
    self.indexView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    self.indexView.fontColor = APP_SUB_THEME_COLOR;
    self.indexView.selectedItemFontColor = APP_SUB_THEME_COLOR_HIGHLIGHT;
    self.indexView.dataSource = self;

    [self.indexView setFrame:CGRectMake(0, 0, kWindowWidth-5, kWindowHeight)];
    [self.indexView refreshIndexItems];
    [self.view addSubview:self.indexView];
}

- (void)dealloc
{
     if (!_isPushed) {
         [[NSNotificationCenter defaultCenter] removeObserver:self];
     }
}

#pragma mark - setter & getter

- (SelectContactScrollView *)selectContactView
{
    if (!_selectContactView) {
        _selectContactView = [[SelectContactScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 90)];
        _selectContactView.delegate = self;
        _selectContactView.backgroundColor = [UIColor whiteColor];
        _selectContactView.alpha = 0;
    }
    return _selectContactView;
}

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        CGFloat offsetY = 64+10;
        _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, offsetY, kWindowWidth, [UIApplication sharedApplication].keyWindow.frame.size.height - offsetY)];
        _contactTableView.dataSource = self;
        
        NSLog(@"%f", self.view.frame.size.height);
        
        _contactTableView.delegate = self;
        _contactTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _contactTableView.backgroundColor = APP_PAGE_COLOR;
        _contactTableView.showsVerticalScrollIndicator = NO;
        [self.contactTableView registerNib:[UINib nibWithNibName:@"CreateConversationTableViewCell" bundle:nil] forCellReuseIdentifier:contactCell];
        _contactTableView.sectionIndexColor = APP_SUB_THEME_COLOR;
    }
    return _contactTableView;
}

- (NSMutableArray *)selectedContacts
{
    if (!_selectedContacts) {
        _selectedContacts = [[NSMutableArray alloc] init];
    }
    return _selectedContacts;
}

- (NSDictionary *)dataSource
{
    if (!_dataSource) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        _dataSource = [accountManager contactsByPinyin];
    }
    return _dataSource;
}

#pragma mark - IBAction Methods

- (IBAction)dismissCtl:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createConversation:(id)sender
{
    if (_group) {         //如果是向已有的群组里添加新的成员
        [self didAddNumberToGroup];

    } else {
        if (self.selectedContacts.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"请选择一个以上好友"];
            
        } else if (self.selectedContacts.count == 1) {    //只选择一个视为单聊
            Contact *contact = [self.selectedContacts firstObject];
            if (_delegate && [_delegate respondsToSelector:@selector(createConversationSuccessWithChatter:isGroup:chatTitle:)]) {
                [_delegate createConversationSuccessWithChatter:contact.easemobUser isGroup:NO chatTitle:contact.nickName];
            }
            
        } else if (self.selectedContacts.count > 1) {     //群聊
            [self showHudInView:self.view hint:@"创建群组..."];
            
            NSMutableArray *source = [NSMutableArray array];
            for (Contact *buddy in self.selectedContacts) {
                [source addObject:buddy.easemobUser];
            }
            
            Contact *firstContact = [self.selectedContacts firstObject];
            Contact *secondContact = [self.selectedContacts objectAtIndex:1];
            NSString *groupName = [NSString stringWithFormat:@"%@,%@",firstContact.nickName, secondContact.nickName];

            EMGroupStyleSetting *setting = [[EMGroupStyleSetting alloc] init];
            setting.groupStyle = eGroupStyle_PrivateMemberCanInvite;
            
            AccountManager *accountManager = [AccountManager shareAccountManager];
            NSString *messageStr = [NSString stringWithFormat:@"%@ 邀请你加入群组\'%@\'", accountManager.account.nickName, groupName];
            __weak CreateConversationViewController *weakSelf = self;
            
            [[EaseMob sharedInstance].chatManager asyncCreateGroupWithSubject:groupName description:@"" invitees:source initialWelcomeMessage:messageStr styleSetting:setting completion:^(EMGroup *group, EMError *error) {
                [weakSelf hideHud];
                if (group && !error) {
                    [[EaseMob sharedInstance].chatManager setApnsNickname:groupName];
                    [weakSelf sendMsgWhileCreateGroup:group.groupId];
                    if (_delegate && [_delegate respondsToSelector:@selector(createConversationSuccessWithChatter:isGroup:chatTitle:)]) {
                        [_delegate createConversationSuccessWithChatter:group.groupId isGroup:YES chatTitle:group.groupSubject];
                    }

                }
                else{
                    [weakSelf showHint:@"吖~好像请求失败了"];
                }
            } onQueue:nil];

        }
    }
}


#pragma mark - Private Methods

//当群主创建了一个群组，向群里发送一条欢迎语句
- (void)sendMsgWhileCreateGroup:(NSString *)groupId
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    NSMutableString *messageStr = [NSMutableString stringWithFormat:@"%@邀请了",accountManager.account.nickName];
    for (Contact *contact in self.selectedContacts) {
        [messageStr appendString:[NSString stringWithFormat:@"%@ ", contact.nickName]];
    }
    [messageStr appendString:@"加入了群聊"];
    NSDictionary *messageDic = @{@"tzType":[NSNumber numberWithInt:TZTipsMsg], @"content":messageStr};
    
    EMMessage *message = [ChatSendHelper sendTaoziMessageWithString:messageStr andExtMessage:messageDic toUsername:groupId isChatGroup:YES requireEncryption:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:updateChateViewNoti object:nil userInfo:@{@"message":message}];

}

- (void)tableViewMoveToCorrectPosition:(NSInteger)currentIndex
{
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:currentIndex];
    [self.contactTableView scrollToRowAtIndexPath:scrollIndexPath
                                 atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)isSelected:(NSString *)easeMobUserName
{
    for (Contact *contact in self.selectedContacts) {
        if ([easeMobUserName isEqualToString: contact.easemobUser]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isNumberInGroup:(NSString *)easeMobUserName
{
    for (NSString *userName in self.emGroup.occupants) {
        if ([easeMobUserName isEqualToString: userName]) {
            return YES;
        }
    }
    return NO;
}

- (void)didAddNumberToGroup
{
     __weak typeof(CreateConversationViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *source = [NSMutableArray array];
        for (Contact *contact in self.selectedContacts) {
            [source addObject:contact.easemobUser];
        }
        
        EMError *error = nil;
        [[EaseMob sharedInstance].chatManager addOccupants:source toGroup:weakSelf.group.groupId welcomeMessage:@"" error:&error];
        if (!error) {
            [hud hideTZHUD];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_group addNumbers:[NSSet setWithArray:self.selectedContacts]];
                AccountManager *accountManager = [AccountManager shareAccountManager];
                [accountManager addNumberToGroup:_group.groupId numbers:[NSSet setWithArray:self.selectedContacts]];
                [self sendMsgWhileCreateGroup:_group.groupId];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            [hud hideTZHUD];
            [SVProgressHUD showErrorWithStatus:@"好像请求失败了"];
        }
    });
}

#pragma mark - TZScollViewDelegate

- (void)moveToIndex:(NSInteger)index
{
    [self tableViewMoveToCorrectPosition:index];
}

#pragma mark -  TaoziSelectViewDelegate

- (void)removeUintCell:(NSInteger)index
{
    [self.selectedContacts removeObjectAtIndex:index];
    if (self.selectedContacts.count == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.selectContactView.alpha = 0.2;
            
            CGRect frame = CGRectMake(self.contactTableView.frame.origin.x, self.contactTableView.frame.origin.y - self.selectContactView.frame.size.height, self.contactTableView.frame.size.width, self.contactTableView.frame.size.height + self.selectContactView.frame.size.height);
            [self.contactTableView setFrame:frame];
            
        } completion:^(BOOL finished) {
            self.selectContactView.alpha = 0;
        }];
        self.navigationItem.rightBarButtonItem.tintColor = TEXT_COLOR_TITLE_SUBTITLE;
        self.navigationItem.rightBarButtonItem.title = @"确定 ";
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"确定(%lu)", (unsigned long)self.selectedContacts.count];
    }
    [self.contactTableView reloadData];
}

#pragma mark - UITableVeiwDataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.dataSource objectForKey:@"headerKeys"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contactTableView.frame.size.width, 30)];
    sectionView.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.text = [NSString stringWithFormat:@"  %@", [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section]];
    
    [sectionView addSubview:label];
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, self.contactTableView.frame.size.width, 1)];
    spaceView.backgroundColor = UIColorFromRGB(0xeeeeee);
    [sectionView addSubview:spaceView];
    
    return sectionView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *contacts = [[self.dataSource objectForKey:@"content"] objectAtIndex:section];
    return [contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    CreateConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
    cell.nickNameLabel.text = contact.nickName;
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatarSmall] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    if ([self isSelected:contact.easemobUser]) {
        cell.checkStatus = checked;
    } else {
        cell.checkStatus = unChecked;
    }
    if ([self isNumberInGroup:contact.easemobUser]) {
        cell.checkStatus = disable;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([self isNumberInGroup:contact.easemobUser]) {
        return;
    }
    if ([self isSelected:contact.easemobUser]) {
        NSInteger index = [self.selectedContacts indexOfObject:contact];
        [self.selectContactView removeUnitAtIndex:index];
        
    } else {
        if (self.selectedContacts.count == 0) {
            
            [UIView animateWithDuration:0.3 animations:^{
                self.selectContactView.alpha = 0.8;
                CGRect frame = CGRectMake(self.contactTableView.frame.origin.x, self.contactTableView.frame.origin.y+self.selectContactView.frame.size.height, self.contactTableView.frame.size.width, self.contactTableView.frame.size.height - self.selectContactView.frame.size.height);
                [self.contactTableView setFrame:frame];
            } completion:^(BOOL finished) {
                self.selectContactView.alpha = 1.0;
            }];
            
            self.navigationItem.rightBarButtonItem.tintColor = APP_THEME_COLOR;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        [self.selectedContacts addObject:contact];
        SelectContactUnitView *unitView = [[SelectContactUnitView alloc] initWithFrame:CGRectMake(0, 0, 40, 80)];
        [unitView.avatarBtn sd_setImageWithURL:[NSURL URLWithString:contact.avatarSmall] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
        unitView.nickNameLabel.text = contact.nickName;
        [self.selectContactView addSelectUnit:unitView];
        self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"确定(%ld)", (unsigned long)self.selectedContacts.count];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark MJMIndexForTableView datasource methods
// 索引目录
-(NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView
{
    return [self.dataSource objectForKey:@"headerKeys"];
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    [self.contactTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index] atScrollPosition: UITableViewScrollPositionTop animated:YES];

}


@end
