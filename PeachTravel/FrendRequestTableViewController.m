//
//  FrendRequestTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FrendRequestTableViewController.h"
#import "FrendRequest.h"
#import "AccountManager.h"

#define requestCell      @"requestCell"

@interface FrendRequestTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) AccountManager *accountManager;

@end

@implementation FrendRequestTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"好友申请";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:requestCell];
}

#pragma mark - setter & getter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        NSComparator cmptr = ^(FrendRequest *obj1, FrendRequest *obj2) {
            if ([obj1.requestDate doubleValue] < [obj2.requestDate doubleValue]) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        };
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id request in self.accountManager.account.frendrequestlist) {
            [tempArray addObject:request];
        }
        _dataSource = [[tempArray sortedArrayUsingComparator:cmptr] mutableCopy];
    }
    return _dataSource;
}

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:requestCell forIndexPath:indexPath];
    FrendRequest *request = [_dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = request.nickName;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FrendRequest *frendRequest = [self.dataSource objectAtIndex:indexPath.row];
        [self.accountManager removeFrendRequest:frendRequest];
        [self.dataSource removeObject:frendRequest];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
