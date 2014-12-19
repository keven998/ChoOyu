//
//  ContactListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/30.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ContactListViewController.h"
#import "AccountManager.h"
#import "TZScrollView.h"
#import "ChatViewController.h"
#import "FrendRequestTableViewController.h"
#import "ContactDetailViewController.h"
#import "ContactListTableViewCell.h"
#import "OptionOfFASKTableViewCell.h"
#import "AddContactTableViewController.h"

#define contactCell      @"contactCell"
#define requestCell      @"requestCell"

@interface ContactListViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, TZScrollViewDelegate>

@property (strong, nonatomic) TZScrollView *tzScrollView;
@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) AccountManager *accountManager;

//是否显示字母索引，当少于15个人的时候不显示
@property (nonatomic) BOOL showRefrence;

@property (strong, nonatomic) UIView *emptyView;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.accountManager loadContactsFromServer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactList) name:contactListNeedUpdateNoti object:nil];
    [self.contactTableView registerNib:[UINib nibWithNibName:@"OptionOfFASKTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"friend_ask"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager.account.contacts count] > 15) {
        _showRefrence = YES;
    }
    
    if (_showRefrence) {
        [self.view addSubview:self.tzScrollView];
    }
    [self.view addSubview:self.contactTableView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.accountManager numberOfUnReadFrendRequest]) {
        self.notify = YES;
    } else {
        self.notify = NO;
    }
    if (self.contactTableView.numberOfSections > 0) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.contactTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    __weak ContactListViewController *weakSelf = self;
    [self.delegate updateNotify:weakSelf notify:self.notify];
    [self handleEmptyView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 0.0, width - 50.0, 32.0)];
    label.font = [UIFont systemFontOfSize:13.0];
    label.textColor = UIColorFromRGB(0x999999);
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"快邀爱旅行的蜜蜜们到Talk来吧，旅行交流更方便啦~";
    [self.emptyView addSubview:label];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_indicator.png"]];
    imgView.center = CGPointMake(width*0.30, 55.0);
    [self.emptyView addSubview:imgView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.0, 0.0, 108.0, 34.0);
    btn.backgroundColor = UIColorFromRGB(0xee528c);
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"添加桃友" forState:UIControlStateNormal];
    btn.center = CGPointMake(width/2.0, 108.0);
    btn.layer.cornerRadius = 2.0;
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

- (TZScrollView *)tzScrollView
{
    if (!_tzScrollView) {
        
        _tzScrollView = [[TZScrollView alloc] initWithFrame:CGRectMake(0, 10, kWindowWidth, 52)];
        _tzScrollView.itemWidth = 22;
        _tzScrollView.itemHeight = 22;
        _tzScrollView.itemBackgroundColor = [UIColor grayColor];
        _tzScrollView.backgroundColor = [UIColor whiteColor];
        _tzScrollView.delegate = self;
        _tzScrollView.layer.borderWidth = 1.0;
        _tzScrollView.layer.borderColor = APP_PAGE_COLOR.CGColor;
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        [titles addObject:@"@"];
        for (NSString *s in [self.dataSource objectForKey:@"headerKeys"]) {
            [titles addObject:s];
        }
        _tzScrollView.titles = titles;
    }
    return _tzScrollView;
}
- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        CGFloat offsetY = 10;
        if (_showRefrence) {
            offsetY += self.tzScrollView.frame.size.height;
        }
        _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(11, offsetY, kWindowWidth-22, [UIApplication sharedApplication].keyWindow.frame.size.height - offsetY - 64 - 44) ];
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
        _contactTableView.backgroundColor = APP_PAGE_COLOR;
        _contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _contactTableView.showsVerticalScrollIndicator = NO;
        [_contactTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:requestCell];
        [_contactTableView registerNib:[UINib nibWithNibName:@"ContactListTableViewCell" bundle:nil] forCellReuseIdentifier:contactCell];
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

#pragma mark - IBAction Methods

- (IBAction)choseCurrent:(UIButton *)sender
{
    _tzScrollView.currentIndex = sender.tag;
    [self tableViewMoveToCorrectPosition:sender.tag];
}


#pragma mark - Private Methods

- (void)updateContactList
{
    self.dataSource = [self.accountManager contactsByPinyin];
    [self.contactTableView reloadData];
    
    [self handleEmptyView];
}

- (void)tableViewMoveToCorrectPosition:(NSInteger)currentIndex
{
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:currentIndex];
    [self.contactTableView scrollToRowAtIndexPath:scrollIndexPath
                                 atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - TZScollViewDelegate

- (void)moveToIndex:(NSInteger)index
{
    [self tableViewMoveToCorrectPosition:index];
}

#pragma mark - UITableVeiwDataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.dataSource objectForKey:@"headerKeys"] count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 54.0;
    }
    
    return 54.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 26.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25.0)];
        view.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 25.0)];
        label.text = [NSString stringWithFormat:@"    %@", [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section-1]];
        label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12.0];
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
        if (self.notify) {
            cell.notifyFlag.hidden = NO;
        } else {
            cell.notifyFlag.hidden = YES;
        }
        return cell;
        
    } else {
        Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        ContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
        cell.nickNameLabel.text = contact.nickName;
        if (contact.signature) {
            cell.phoneLabel.text = contact.signature;
        } else {
            cell.phoneLabel.text = @"未设置签名";
        }
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FrendRequestTableViewController *frendRequestCtl = [[FrendRequestTableViewController alloc] init];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[OptionOfFASKTableViewCell class]]) {
            OptionOfFASKTableViewCell *oc = (OptionOfFASKTableViewCell *)cell;
            oc.notifyFlag.hidden = YES;
            self.notify = NO;
        }
        [self.navigationController pushViewController:frendRequestCtl animated:YES];
    } else {
        Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        ContactDetailViewController *contactDetailCtl = [[ContactDetailViewController alloc] init];
        contactDetailCtl.contact = contact;
        [self.navigationController pushViewController:contactDetailCtl animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
