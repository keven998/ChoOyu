//
//  CreateCoversationViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "CreateConversationViewController.h"
#import "TZScrollView.h"
#import "pinyin.h"
#import "AccountManager.h"
#import "ChatView/ChatViewController.h"
#import "CreateConversationTableViewCell.h"
#import "ChatView/ChatSendHelper.h"
#import "SelectContactScrollView.h"
#import "SelectContactUnitView.h"

#define contactCell      @"createConversationCell"

@interface CreateConversationViewController ()<UIScrollViewDelegate, UITableViewDataSource,TZScrollViewDelegate, UITableViewDelegate, TaoziSelectViewDelegate>

@property (strong, nonatomic) TZScrollView *tzScrollView;
@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) SelectContactScrollView *selectContactView;

@end

@implementation CreateConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [self.view addSubview:self.selectContactView];
    [self.view addSubview:self.tzScrollView];
    [self.view addSubview:self.contactTableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *confirm = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [confirm setTitle:@"确认" forState:UIControlStateNormal];
    [confirm setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [confirm addTarget:self action:@selector(createConversation:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:confirm];
}

#pragma mark - setter & getter

- (TZScrollView *)tzScrollView
{
    if (!_tzScrollView) {
        
        _tzScrollView = [[TZScrollView alloc] initWithFrame:CGRectMake(0, 164, kWindowWidth, 40)];
        _tzScrollView.itemWidth = 20;
        _tzScrollView.itemHeight = 20;
        _tzScrollView.itemBackgroundColor = [UIColor grayColor];
        _tzScrollView.backgroundColor = [UIColor whiteColor];
        _tzScrollView.delegate = self;
        _tzScrollView.titles = [self.dataSource objectForKey:@"headerKeys"];
        _tzScrollView.delegate = self;
    }
    return _tzScrollView;
}

- (SelectContactScrollView *)selectContactView
{
    if (!_selectContactView) {
        _selectContactView = [[SelectContactScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 90)];
        _selectContactView.delegate = self;
        _selectContactView.backgroundColor = [UIColor whiteColor];
    }
    return _selectContactView;
}

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.tzScrollView.frame.origin.y+self.tzScrollView.frame.size.height+10, kWindowWidth-20, [UIApplication sharedApplication].keyWindow.frame.size.height-self.tzScrollView.frame.origin.y - self.tzScrollView.frame.size.height)];
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
        _contactTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _contactTableView.backgroundColor = APP_PAGE_COLOR;
        [self.contactTableView registerNib:[UINib nibWithNibName:@"CreateConversationTableViewCell" bundle:nil] forCellReuseIdentifier:contactCell];
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

- (IBAction)createConversation:(id)sender
{
    if (_group) {         //如果是向已有的群组里添加新的成员
        [self didAddNumberToGroup];

    } else {
        NSLog(@"我选择的聊天好友为：%@", self.selectedContacts);
        if (self.selectedContacts.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"一个都不选聊天球啊"];
            
        } else if (self.selectedContacts.count == 1) {    //只选择一个视为单聊
            Contact *contact = [self.selectedContacts firstObject];
            ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:contact.easemobUser isGroup:NO];
            chatVC.title = contact.nickName;
            if (_delegate && [_delegate respondsToSelector:@selector(createConversationSuccessWithChatter:isGroup:)]) {
                [_delegate createConversationSuccessWithChatter:contact.easemobUser isGroup:NO];
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
                    NSLog(@"%@", [NSThread currentThread]);
                    [weakSelf showHint:@"创建群组成功"];
                    [[EaseMob sharedInstance].chatManager setNickname:groupName];
                    [weakSelf sendMsgWhileCreateGroup:group.groupId];
                    ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:group.groupId isGroup:YES];
                    chatVC.title = group.groupSubject;
                    if (_delegate && [_delegate respondsToSelector:@selector(createConversationSuccessWithChatter:isGroup:)]) {
                        [_delegate createConversationSuccessWithChatter:group.groupId isGroup:YES];
                    }

                }
                else{
                    [weakSelf showHint:@"创建群组失败，请重新操作"];
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
    NSDictionary *messageDic = @{@"tzType":@100, @"content":messageStr};
    
    [ChatSendHelper sendTaoziMessageWithString:messageStr andExtMessage:messageDic toUsername:groupId isChatGroup:YES requireEncryption:NO];
}

- (void)tableViewMoveToCorrectPosition:(NSInteger)currentIndex
{
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:currentIndex];
    [self.contactTableView scrollToRowAtIndexPath:scrollIndexPath
                                 atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)isSelected:(NSNumber *)userId
{
    for (Contact *contact in self.selectedContacts) {
        if (userId.integerValue == contact.userId.integerValue) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isNumberInGroup:(NSNumber *)userId
{
    for (Contact *contact in self.group.numbers) {
        if (userId.integerValue == contact.userId.integerValue) {
            return YES;
        }
    }
    return NO;
}

- (void)didAddNumberToGroup
{
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *source = [NSMutableArray array];
        for (Contact *contact in self.selectedContacts) {
            [source addObject:contact.easemobUser];
        }
        [SVProgressHUD show];
        EMError *error = nil;
        [[EaseMob sharedInstance].chatManager addOccupants:source toGroup:weakSelf.group.groupId welcomeMessage:@"" error:&error];
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                [_group addNumbers:[NSSet setWithArray:self.selectedContacts]];
                AccountManager *accountManager = [AccountManager shareAccountManager];
                [accountManager addNumberToGroup:_group.groupId numbers:[NSSet setWithArray:self.selectedContacts]];
                [self sendMsgWhileCreateGroup:_group.groupId];
            });
            
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
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    if ([self isSelected:contact.userId]) {
        cell.checkStatus = checked;
    } else {
        cell.checkStatus = unChecked;
    }
    if ([self isNumberInGroup:contact.userId]) {
        cell.checkStatus = disable;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([self isNumberInGroup:contact.userId]) {
        return;
    }
    if ([self isSelected:contact.userId]) {
        NSInteger index = [self.selectedContacts indexOfObject:contact];
        [self.selectContactView removeUnitAtIndex:index];
        
    } else {
        [self.selectedContacts addObject:contact];
        SelectContactUnitView *unitView = [[SelectContactUnitView alloc] initWithFrame:CGRectMake(0, 0, 40, 80)];
        [unitView.avatarBtn sd_setImageWithURL:[NSURL URLWithString:contact.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
        unitView.nickNameLabel.text = contact.nickName;
        [self.selectContactView addSelectUnit:unitView];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *visiableCells = [self.contactTableView visibleCells];
    NSIndexPath *indexPath = [self.contactTableView indexPathForCell:[visiableCells firstObject]];
    self.tzScrollView.currentIndex = indexPath.section;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    NSArray *visiableCells = [self.contactTableView visibleCells];
    NSIndexPath *indexPath = [self.contactTableView indexPathForCell:[visiableCells firstObject]];
    self.tzScrollView.currentIndex = indexPath.section;
}


@end
