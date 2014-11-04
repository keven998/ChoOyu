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

#define contactCell      @"createConversationCell"

@interface CreateConversationViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) TZScrollView *tzScrollView;
@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) NSMutableArray *selectedContacts;

@end

@implementation CreateConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
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
        
        _tzScrollView = [[TZScrollView alloc] initWithFrame:CGRectMake(0, 144, [UIApplication sharedApplication].keyWindow.frame.size.width, 40)];
        _tzScrollView.scrollView.delegate = self;
        _tzScrollView.itemWidth = 80;
        _tzScrollView.itemHeight = 40;
        _tzScrollView.itemBackgroundColor = [UIColor greenColor];
        _tzScrollView.backgroundColor = [UIColor greenColor];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i<[[self.dataSource objectForKey:@"headerKeys"] count]; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
            NSString *s = [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:i];
            [button setTitle:s forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor greenColor]];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            button.tag = i;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [array addObject:button];
        }
        _tzScrollView.viewsOnScrollView = array;
        for (UIButton *tempBtn in _tzScrollView.viewsOnScrollView) {
            [tempBtn addTarget:self action:@selector(choseCurrent:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _tzScrollView;
}

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.tzScrollView.frame.origin.y+self.tzScrollView.frame.size.height, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height-self.tzScrollView.frame.origin.y - self.tzScrollView.frame.size.height)];
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
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

- (IBAction)choseCurrent:(UIButton *)sender
{
    _tzScrollView.currentIndex = sender.tag;
    [self tableViewMoveToCorrectPosition:sender.tag];
}

- (IBAction)createConversation:(id)sender
{
    NSLog(@"我选择的聊天好友为：%@", self.selectedContacts);
    if (self.selectedContacts.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"一个都不选聊天球啊"];
        
    } else if (self.selectedContacts.count == 1) {    //只选择一个视为单聊
        Contact *contact = [self.selectedContacts firstObject];
        ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:contact.easemobUser isGroup:NO];
        chatVC.title = contact.nickName;
        [self.navigationController pushViewController:chatVC animated:YES];
        
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
                [weakSelf showHint:@"创建群组成功"];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                [weakSelf showHint:@"创建群组失败，请重新操作"];
            }
        } onQueue:nil];

    }
}

#pragma mark - Private Methods

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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.backgroundColor = [UIColor grayColor];
    
    label.text = [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section];
    return label;
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
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:nil];
    if ([self isSelected:contact.userId]) {
        cell.selectImageView.backgroundColor = [UIColor redColor];
    } else {
        cell.selectImageView.backgroundColor = [UIColor greenColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if ([self isSelected:contact.userId]) {
        [self.selectedContacts removeObject:contact];
    } else {
        [self.selectedContacts addObject:contact];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.tzScrollView.scrollView) {
        CGPoint currentOffset = scrollView.contentOffset;
        
        NSLog(@"offset: %@", NSStringFromCGPoint(currentOffset));
        
        int currentIndex = (int)(currentOffset.x)/80;
        if (currentIndex > [[self.dataSource objectForKey:@"headerKeys"] count]-1) {
            currentIndex = [[self.dataSource objectForKey:@"headerKeys"] count]-1;
        }
        if (currentIndex < 0) {
            currentIndex = 0;
        }
        _tzScrollView.currentIndex = currentIndex;
        [self tableViewMoveToCorrectPosition:currentIndex];
        
    } else if (scrollView == self.contactTableView) {
        NSArray *visiableCells = [self.contactTableView visibleCells];
        NSIndexPath *indexPath = [self.contactTableView indexPathForCell:[visiableCells firstObject]];
        self.tzScrollView.currentIndex = indexPath.section;
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if (scrollView == self.tzScrollView.scrollView) {
        CGPoint currentOffset = scrollView.contentOffset;
        int currentIndex = (int)(currentOffset.x)/80;
        if (currentIndex > [[self.dataSource objectForKey:@"headerKeys"] count]-1) {
            currentIndex = [[self.dataSource objectForKey:@"headerKeys"] count]-1;
        }
        if (currentIndex < 0) {
            currentIndex = 0;
        }
        _tzScrollView.currentIndex = currentIndex;
        [self tableViewMoveToCorrectPosition:currentIndex];
        
    } else if (scrollView == self.contactTableView) {
        NSArray *visiableCells = [self.contactTableView visibleCells];
        NSIndexPath *indexPath = [self.contactTableView indexPathForCell:[visiableCells firstObject]];
        self.tzScrollView.currentIndex = indexPath.section;
    }
}


@end
