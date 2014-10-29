//
//  ContactListTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/24.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ContactListTableViewController.h"
#import "AccountManager.h"
#import "ChatViewController.h"

#define contactCell         @"contactCellIdentifier"

@interface ContactListTableViewController ()

@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) AccountManager *accountManager;

@end

@implementation ContactListTableViewController

#pragma mark - LifeCycel

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:contactCell];
}

#pragma mark - setter & getter

- (NSMutableArray *)contacts
{
    if (!_contacts) {
        NSSet *tempContacts = self.accountManager.account.contacts;
        _contacts = [[NSMutableArray alloc] init];
        for (id contact in tempContacts) {
            [_contacts addObject:contact];
        }
    }
    return _contacts;
}

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactCell forIndexPath:indexPath];
    Contact *contact = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = contact.userName;
    return cell;
}

 #pragma mark - Table view delegate

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     Contact *contact = [self.contacts objectAtIndex:indexPath.row];
     ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:contact.easemobUser isGroup:NO];
     chatVC.title = contact.easemobUser;
     [_rootCtl.navigationController pushViewController:chatVC animated:YES];
 }


@end
