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

@property (strong, nonatomic) UIView *emptyView;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.tzScrollView];
    [self.view addSubview:self.contactTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactList) name:contactListNeedUpdateNoti object:nil];
    
    [self.contactTableView registerNib:[UINib nibWithNibName:@"OptionOfFASKTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"friend_ask"];
}

- (void) viewWillAppear:(BOOL)animated {
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
    CGFloat width = CGRectGetWidth(self.view.frame);
    
    self.emptyView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 192.0)];
    self.emptyView.userInteractionEnabled = YES;
    self.emptyView.center = CGPointMake(self.view.frame.size.width/2.0, 160.0);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 0.0, width - 50.0, 32.0)];
    label.font = [UIFont systemFontOfSize:13.0];
    label.textColor = UIColorFromRGB(0x999999);
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"快邀爱旅行的蜜蜜们到旅行圈来吧，旅行交流更方便啦~";
    [self.emptyView addSubview:label];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_notify_flag.png"]];
    imgView.center = CGPointMake(width*0.30, 55.0);
    [self.emptyView addSubview:imgView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.0, 0.0, 108.0, 34.0);
    btn.backgroundColor = UIColorFromRGB(0xee528c);
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"添加旅友" forState:UIControlStateNormal];
    btn.center = CGPointMake(width/2.0, 108.0);
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
        
        _tzScrollView = [[TZScrollView alloc] initWithFrame:CGRectMake(0, 10, kWindowWidth, 40)];
        _tzScrollView.itemWidth = 20;
        _tzScrollView.itemHeight = 20;
        _tzScrollView.itemBackgroundColor = [UIColor grayColor];
        _tzScrollView.backgroundColor = [UIColor whiteColor];
        _tzScrollView.delegate = self;
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        [titles addObject:@"好友请求"];
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
        _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.tzScrollView.frame.origin.y+self.tzScrollView.frame.size.height, kWindowWidth, [UIApplication sharedApplication].keyWindow.frame.size.height-self.tzScrollView.frame.origin.y - self.tzScrollView.frame.size.height-64) ];
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
        _contactTableView.backgroundColor = APP_PAGE_COLOR;
        _contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _contactTableView.contentInset = UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0);
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

- (void)removeContact:(NSNumber *)userId atIndex:(NSIndexPath *)indexPath
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@",self.accountManager.account.userId] forHTTPHeaderField:@"UserId"];

    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_DELETE_CONTACTS, userId];
    
    [SVProgressHUD show];
    
    //删除联系人
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self.accountManager removeContact:userId];
            [self updateContactList];
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
        } else {
            [SVProgressHUD showErrorWithStatus:@"删除失败"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"删除失败"];
    }];

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
        return 55.0;
    }
    
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 24.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, tableView.frame.size.width - 20.0, 24.0)];
//        label.text = [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section-1];
        label.text = [NSString stringWithFormat:@"    %@", [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section-1]];
        label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = UIColorFromRGB(0x999999);
        label.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
        label.layer.borderWidth = 0.5;
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        [self removeContact:contact.userId atIndex:indexPath];
    }
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
