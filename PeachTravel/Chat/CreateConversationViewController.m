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

//是否显示字母索引，当少于15个人的时候不显示
@property (nonatomic) BOOL showRefrence;

//@property (nonatomic, strong)  UIButton *confirm;

@end

@implementation CreateConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.title = @"选择Talk桃友";
    /**
     *  如果联系人的个数大于15，那显示索引，反之不现实
     */
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager.account.contacts count] > 15) {
        _showRefrence = YES;
    }
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.selectContactView];
    if (_showRefrence) {
        [self.view addSubview:self.tzScrollView];
    }
    [self.view addSubview:self.contactTableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    _confirm = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
//    [_confirm setTitle:@"确定" forState:UIControlStateNormal];
//    _confirm.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17.0];
//    [_confirm setTitleColor:UIColorFromRGB(0x797979) forState:UIControlStateNormal];
//    _confirm.userInteractionEnabled = NO;
//    _confirm.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    [_confirm addTarget:self action:@selector(createConversation:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_confirm];
    
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc]initWithTitle:@"确定 " style:UIBarButtonItemStyleBordered target:self action:@selector(createConversation:)];
    confirm.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = confirm;
    
    if (!_isPushed) {
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@" 取消" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissCtl:)];
        backBtn.tintColor = TEXT_COLOR_TITLE_SUBTITLE;
        self.navigationItem.leftBarButtonItem = backBtn;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissCtl:) name:userDidLogoutNoti object:nil];
    }
}

- (void)dealloc
{
     if (!_isPushed) {
         [[NSNotificationCenter defaultCenter] removeObserver:self];
     }
}

#pragma mark - setter & getter

- (TZScrollView *)tzScrollView
{
    if (!_tzScrollView) {
        _tzScrollView = [[TZScrollView alloc] initWithFrame:CGRectMake(0, self.selectContactView.frame.origin.y + 10, kWindowWidth, 52)];
        _tzScrollView.itemWidth = 22;
        _tzScrollView.itemHeight = 22;
        _tzScrollView.itemBackgroundColor = UIColorFromRGB(0xd2d2d2);
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
        _selectContactView.alpha = 0;
    }
    return _selectContactView;
}

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        CGFloat offsetY = 64+10;
        if (_showRefrence) {
            offsetY += self.tzScrollView.frame.size.height + 10;
        }
        _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(11, offsetY, kWindowWidth-22, [UIApplication sharedApplication].keyWindow.frame.size.height - offsetY)];
        _contactTableView.dataSource = self;
        
        NSLog(@"%f", self.view.frame.size.height);
        
        _contactTableView.delegate = self;
        _contactTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _contactTableView.backgroundColor = APP_PAGE_COLOR;
        _contactTableView.showsVerticalScrollIndicator = NO;
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
            [SVProgressHUD showErrorWithStatus:@"呃~我还不知道你想和谁Talk"];
            
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
            
            if (_showRefrence) {
                CGRect refrenceFrame = CGRectMake(self.tzScrollView.frame.origin.x, self.tzScrollView.frame.origin.y - self.selectContactView.frame.size.height, self.tzScrollView.frame.size.width, self.tzScrollView.frame.size.height);
                [self.tzScrollView setFrame:refrenceFrame];
            }

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
        if (self.selectedContacts.count == 0) {
            
            [UIView animateWithDuration:0.3 animations:^{
                self.selectContactView.alpha = 0.8;
                CGRect frame = CGRectMake(self.contactTableView.frame.origin.x, self.contactTableView.frame.origin.y+self.selectContactView.frame.size.height, self.contactTableView.frame.size.width, self.contactTableView.frame.size.height - self.selectContactView.frame.size.height);
                [self.contactTableView setFrame:frame];
                if (_showRefrence) {
                    CGRect refrenceFrame = CGRectMake(self.tzScrollView.frame.origin.x, self.tzScrollView.frame.origin.y + self.selectContactView.frame.size.height, self.tzScrollView.frame.size.width, self.tzScrollView.frame.size.height);
                    [self.tzScrollView setFrame:refrenceFrame];
                }
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
