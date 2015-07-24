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
#import "CreateConversationTableViewCell.h"
#import "SelectContactScrollView.h"
#import "SelectContactUnitView.h"
#import "PeachTravel-swift.h"

#define contactCell      @"createConversationCell"

@interface CreateConversationViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, TaoziSelectViewDelegate>

@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) SelectContactScrollView *selectContactView;

@end

@implementation CreateConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选择联系人";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    [self.view addSubview:self.selectContactView];
    [self.view addSubview:self.contactTableView];
    
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc]initWithTitle:@"确定 " style:UIBarButtonItemStylePlain target:self action:@selector(createConversation:)];
    confirm.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = confirm;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (self.navigationController.viewControllers.count == 1) {
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@" 取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCtl:)];
        backBtn.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = backBtn;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissCtl:) name:userDidLogoutNoti object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_choose_talk_to"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_choose_talk_to"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter & getter

- (SelectContactScrollView *)selectContactView
{
    if (!_selectContactView) {
        _selectContactView = [[SelectContactScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 90)];
        _selectContactView.delegate = self;
        _selectContactView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _selectContactView.backgroundColor = [UIColor whiteColor];
        _selectContactView.alpha = 0;
    }
    return _selectContactView;
}

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        _contactTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
        _contactTableView.separatorColor = COLOR_LINE;
        _contactTableView.backgroundColor = APP_PAGE_COLOR;
        _contactTableView.showsVerticalScrollIndicator = NO;
        _contactTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contactTableView registerNib:[UINib nibWithNibName:@"CreateConversationTableViewCell" bundle:nil] forCellReuseIdentifier:contactCell];
        _contactTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _contactTableView.sectionIndexColor = COLOR_TEXT_II;
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
            [SVProgressHUD showErrorWithStatus:@"请选择一个以上朋友"];
            
        } else if (self.selectedContacts.count == 1) {    //只选择一个视为单聊
            FrendModel *contact = [self.selectedContacts firstObject];
            if (_delegate && [_delegate respondsToSelector:@selector(createConversationSuccessWithChatter:chatType:chatTitle:)]) {
                [_delegate createConversationSuccessWithChatter:contact.userId chatType:IMChatTypeIMChatSingleType chatTitle:contact.nickName];
            }
            
        } else if (self.selectedContacts.count > 1) {     //群聊
            [self showHudInView:self.view hint:@"创建群组..."];
            
            IMDiscussionGroupManager *discussionGroupManager = [IMDiscussionGroupManager shareInstance];
            NSMutableString *subject = [[NSMutableString alloc] initWithString: [AccountManager shareAccountManager].account.nickName];
            for (FrendModel *model in self.selectedContacts) {
                [subject appendString:[NSString stringWithFormat:@", %@", model.nickName]];
            }
            [discussionGroupManager asyncCreateDiscussionGroup:subject invitees: self.selectedContacts completionBlock:^(BOOL isSuccess, NSInteger errCode, IMDiscussionGroup * __nullable discussionGroup) {
                if (isSuccess) {
                    FrendModel *model = self.selectedContacts.firstObject;
                    NSString *groupSubjct = [NSString stringWithFormat:@"测试群组: %@", model.nickName];
                    discussionGroup.subject = groupSubjct;
                    if (_delegate && [_delegate respondsToSelector:@selector(createConversationSuccessWithChatter:chatType:chatTitle:)]) {
                        [_delegate createConversationSuccessWithChatter:discussionGroup.groupId chatType:IMChatTypeIMChatDiscussionGroupType chatTitle:discussionGroup.subject];
                    }
                } else {
                    [self hideHud];
                    [SVProgressHUD showHint:@"创建失败"];
                }
                
            }];
        }
    }
}


#pragma mark - Private Methods

- (void)tableViewMoveToCorrectPosition:(NSInteger)currentIndex
{
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:currentIndex];
    [self.contactTableView scrollToRowAtIndexPath:scrollIndexPath
                                 atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)isSelected:(NSInteger)userId
{
    for (FrendModel *contact in self.selectedContacts) {
        if (userId == contact.userId) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isNumberInGroup:(NSInteger)userId
{
    for (FrendModel *frend in self.group.members) {
        if (frend.userId == userId) {
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
        
        IMDiscussionGroupManager *discussionGroupManager = [IMDiscussionGroupManager shareInstance];
        [discussionGroupManager asyncAddNumbersWithGroup:_group members: self.selectedContacts completion:^(BOOL isSuccess, NSInteger errorCode) {
            [hud hideTZHUD];

            if (isSuccess) {
                [SVProgressHUD showHint:@"添加成功"];
                [self.delegate reloadData];
            } else {
                [SVProgressHUD showHint:@"添加失败"];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
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
        self.navigationItem.rightBarButtonItem.title = @"确定 ";
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"确定(%lu)", (unsigned long)self.selectedContacts.count];
        self.navigationItem.rightBarButtonItem.enabled = YES;
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
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = COLOR_TEXT_II;
    [sectionView addSubview:label];
    return sectionView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *contacts = [[self.dataSource objectForKey:@"content"] objectAtIndex:section];
    return [contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FrendModel *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    CreateConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
    if (contact.memo.length > 0) {
        cell.nickNameLabel.text = contact.memo;
    } else {
        cell.nickNameLabel.text = contact.nickName;
    }
    
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatarSmall] placeholderImage:[UIImage imageNamed:@"ic_home_default_avatar.png"]];
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
    FrendModel *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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
            } completion:^(BOOL finished) {
                self.selectContactView.alpha = 1.0;
            }];
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        [self.selectedContacts addObject:contact];
        SelectContactUnitView *unitView = [[SelectContactUnitView alloc] initWithFrame:CGRectMake(0, 0, 40, 80)];
        [unitView.avatarBtn sd_setImageWithURL:[NSURL URLWithString:contact.avatarSmall] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_home_default_avatar.png"]];
        unitView.nickNameLabel.text = contact.nickName;
        [self.selectContactView addSelectUnit:unitView];
        self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"确定(%ld)", (unsigned long)self.selectedContacts.count];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.dataSource objectForKey:@"headerKeys"];
}


@end
