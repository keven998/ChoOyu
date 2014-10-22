//
//  TravelGroupViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/21.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "TravelGroupViewController.h"
#import "ChatListViewController.h"
#import "ChatViewController.h"

#define contactCell      @"contactCell"

@interface TravelGroupViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactListTableView;

@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation TravelGroupViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _contactListTableView.dataSource = self;
    _contactListTableView.delegate = self;
    [_contactListTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:contactCell];
    [self loadContact];
}

#pragma mark - setter&getter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

#pragma mark - Private Methods

- (void)loadContact
{
    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    for (EMBuddy *buddy in buddyList) {
        if (buddy.followState != eEMBuddyFollowState_NotFollowed) {
            [self.dataSource addObject:buddy.username];
        }
    }
    [_contactListTableView reloadData];
}

#pragma mark - IBAction Methods

- (IBAction)jumpChatList:(UIButton *)sender {
    ChatListViewController *chatListCtl = [[ChatListViewController alloc] init];
    chatListCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatListCtl animated:YES];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:self.dataSource[indexPath.row] isGroup:NO];
    [self.navigationController pushViewController:chatCtl animated:YES];
}


@end
