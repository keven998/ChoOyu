//
//  ContactListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/30.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ContactListViewController.h"
#import "AccountManager.h"
#import "ChatViewController.h"
#import "FrendRequestTableViewController.h"
#import "ContactDetailViewController.h"
#import "ContactListTableViewCell.h"
#import "OptionOfFASKTableViewCell.h"
#import "AddContactTableViewController.h"
#import "ConvertMethods.h"
#import "MJNIndexView.h"


#define contactCell      @"contactCell"
#define requestCell      @"requestCell"

@interface ContactListViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, MJNIndexViewDataSource>

@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) AccountManager *accountManager;

//索引
@property (nonatomic, strong) MJNIndexView *indexView;

@property (strong, nonatomic) UIView *emptyView;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactList) name:contactListNeedUpdateNoti object:nil];
    [self.contactTableView registerNib:[UINib nibWithNibName:@"OptionOfFASKTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"friend_ask"];

    [self.view addSubview:self.contactTableView];
    
    self.indexView = [[MJNIndexView alloc] initWithFrame:self.view.bounds];
    self.indexView.rightMargin = 0;
    self.indexView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    self.indexView.fontColor = APP_SUB_THEME_COLOR;
    self.indexView.selectedItemFontColor = APP_SUB_THEME_COLOR_HIGHLIGHT;
    self.indexView.dataSource = self;
    self.indexView.maxItemDeflection = 60;
    self.indexView.rangeOfDeflection = 1;
    [self.indexView setFrame:CGRectMake(0, 0, kWindowWidth-5, kWindowHeight-64)];
    [self.indexView refreshIndexItems];
    [self.view addSubview:self.indexView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.accountManager loadContactsFromServer];
    [self handleEmptyView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _contactTableView.delegate = nil;
    _emptyView = nil;
}

#pragma mark - private method

- (void) handleEmptyView {
    if ([[self.dataSource objectForKey:@"headerKeys"] count] <= 0) {
        if (self.emptyView == nil) {
            [self setupEmptyView];
        }
    } else {
        [self removeEmptyView];
    }
}

- (void) setupEmptyView {
    CGFloat width = CGRectGetWidth(self.contactTableView.frame);
    
    self.emptyView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 192.0)];
    self.emptyView.userInteractionEnabled = YES;
    self.emptyView.center = CGPointMake(self.view.frame.size.width/2.0, 160.0);
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, width - 50.0, 16.0)];
    label1.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0];
    label1.textColor = APP_THEME_COLOR;
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textAlignment = NSTextAlignmentLeft;
    label1.text = @"蜜蜜新圈子";
    [self.emptyView addSubview:label1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 40.0, width - 50.0, 16.0)];
    label.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    label.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    label.textAlignment = NSTextAlignmentCenter;
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"爱旅行的蜜蜜们之间的专属小天地~";
    [self.emptyView addSubview:label];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_indicator.png"]];
    imgView.center = CGPointMake(width*0.33, 75.0);
    [self.emptyView addSubview:imgView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.0, 0.0, 108.0, 32.0);
    [btn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"加好友" forState:UIControlStateNormal];
    btn.center = CGPointMake(width/2.0, 114.0);
    btn.layer.cornerRadius = 2.0;
    btn.clipsToBounds = YES;
    [btn addTarget:self action:@selector(addUserContact:) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyView addSubview:btn];
    
    [self.contactTableView addSubview:self.emptyView];
}

- (void) removeEmptyView {
    [self.emptyView removeFromSuperview];
    self.emptyView = nil;
}

- (IBAction)addUserContact:(id)sender
{
    AddContactTableViewController *addContactCtl = [[AddContactTableViewController alloc] init];
    [self.navigationController pushViewController:addContactCtl animated:YES];
}

#pragma mark - setter & getter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

- (void)setNumberOfUnreadFrendRequest:(NSUInteger)numberOfUnreadFrendRequest
{
    _numberOfUnreadFrendRequest = numberOfUnreadFrendRequest;
    if (_contactTableView) {
        [_contactTableView reloadData];
    }
}

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        CGFloat offsetY = 0;
        _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, offsetY, self.view.frame.size.width, self.view.frame.size.height - offsetY) style:UITableViewStylePlain];
        
        _contactTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
        
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
        _contactTableView.backgroundColor = APP_PAGE_COLOR;
        _contactTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _contactTableView.showsVerticalScrollIndicator = NO;
        [_contactTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:requestCell];
        [_contactTableView registerNib:[UINib nibWithNibName:@"ContactListTableViewCell" bundle:nil] forCellReuseIdentifier:contactCell];
        _contactTableView.sectionIndexColor = APP_SUB_THEME_COLOR;
    }
    return _contactTableView;
}

- (NSDictionary *)dataSource
{
    if (!_dataSource) {
        _dataSource = [self.accountManager contactsByPinyin];
    }
    return _dataSource;
}

#pragma mark - Private Methods

- (void)updateContactList
{
    self.dataSource = [self.accountManager contactsByPinyin];
    [self.contactTableView reloadData];
   
    [self.indexView setFrame:CGRectMake(0, 0, kWindowWidth-5, kWindowHeight-64)];
    [self.indexView refreshIndexItems];
    
    [self handleEmptyView];
}

- (IBAction)chat:(UIButton *)sender
{
    CGPoint point = [sender convertPoint:CGPointZero toView:self.contactTableView];
    NSIndexPath *indexPath = [self.contactTableView indexPathForRowAtPoint:point];
    Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];

    ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:contact.easemobUser isGroup:NO];
    chatCtl.title = contact.nickName;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    for (EMConversation *conversation in conversations) {
        if ([conversation.chatter isEqualToString:contact.easemobUser]) {
            [conversation markAllMessagesAsRead:YES];
            break;
        }
    }
    [self.navigationController pushViewController:chatCtl animated:YES];
}


#pragma mark - UITableVeiwDataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.dataSource objectForKey:@"headerKeys"] count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44.0;
    }
    
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 26.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25.0)];
        view.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 25.0)];
        label.text = [NSString stringWithFormat:@"    %@", [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section-1]];
        label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];
        label.textColor = UIColorFromRGB(0xadadad);
        label.clipsToBounds = YES;
        label.layer.cornerRadius = 2.0;
        label.layer.shadowColor = APP_DIVIDER_COLOR.CGColor;
        label.layer.shadowOffset = CGSizeMake(0.0, 0.5);
        label.layer.shadowOpacity = 1.0;
        label.layer.shadowRadius = 0.5;
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        NSArray *contacts = [[self.dataSource objectForKey:@"content"] objectAtIndex:section-1];
        return [contacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        OptionOfFASKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friend_ask"];
        cell.numberOfUnreadFrendRequest = _numberOfUnreadFrendRequest;
        return cell;
        
    } else {
        Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        ContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatarSmall] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.png"]];
        cell.nickNameLabel.text = contact.nickName;
        [cell.chatBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FrendRequestTableViewController *frendRequestCtl = [[FrendRequestTableViewController alloc] init];

        [self.navigationController pushViewController:frendRequestCtl animated:YES];
    } else {
        Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        ContactDetailViewController *contactDetailCtl = [[ContactDetailViewController alloc] init];
        contactDetailCtl.contact = contact;
        [self.navigationController pushViewController:contactDetailCtl animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark MJMIndexForTableView datasource methods
// 索引目录
-(NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView
{
    return [self.dataSource objectForKey:@"headerKeys"];
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    [self.contactTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index+1] atScrollPosition: UITableViewScrollPositionTop animated:YES];
}

@end
