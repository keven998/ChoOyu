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

#define contactCell      @"contactCell"

@interface ContactListViewController ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) TZScrollView *tzScrollView;
@property (strong, nonatomic) UITableView *contactTableView;
@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) AccountManager *accountManager;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tzScrollView];
    [self.view addSubview:self.contactTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContactList) name:contactListNeedUpdateNoti object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter & getter

- (TZScrollView *)tzScrollView
{
    if (!_tzScrollView) {
        _tzScrollView = [[TZScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, 40)];
        _tzScrollView.scrollView.delegate = self;
        _tzScrollView.itemWidth = 80;
        _tzScrollView.itemHeight = 40;
        _tzScrollView.itemBackgroundColor = [UIColor greenColor];
        _tzScrollView.backgroundColor = [UIColor greenColor];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        [button setTitle:@"好友申请" forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor greenColor]];
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        button.tag = 0;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [array addObject:button];
        for (int i = 0; i<[[self.dataSource objectForKey:@"headerKeys"] count]; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
            NSString *s = [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:i];
            [button setTitle:s forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor greenColor]];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            button.tag = i+1;
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
        _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.tzScrollView.frame.origin.y+self.tzScrollView.frame.size.height, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height-self.tzScrollView.frame.origin.y - self.tzScrollView.frame.size.height-64) ];
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
        [_contactTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:contactCell];
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
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"删除失败"];
    }];

}

#pragma mark - UITableVeiwDataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.dataSource objectForKey:@"headerKeys"] count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        label.backgroundColor = [UIColor grayColor];
    
        label.text = [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:section-1];
        return label;
    } else return nil;
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
        cell.textLabel.text = @"好友申请";
        return cell;
        
    } else {
        Contact *contact = [[[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
        cell.textLabel.text = contact.nickName;
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
        ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:contact.easemobUser isGroup:NO];
        chatVC.title = contact.nickName;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
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
    if (scrollView == self.tzScrollView.scrollView) {
        CGPoint currentOffset = scrollView.contentOffset;
        int currentIndex = (int)(currentOffset.x)/80;
        if (currentIndex > [[self.dataSource objectForKey:@"headerKeys"] count]) {
            currentIndex = [[self.dataSource objectForKey:@"headerKeys"] count];
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
        if (currentIndex > [[self.dataSource objectForKey:@"headerKeys"] count]) {
            currentIndex = [[self.dataSource objectForKey:@"headerKeys"] count];
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
