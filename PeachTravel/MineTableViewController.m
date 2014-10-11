//
//  MineTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/7.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//
#import "MineTableViewController.h"
#import "LoginTableViewCell.h"
#import "AccountManagerViewController.h"
#import "LoginViewController.h"

#define dataSource               @[@"分享设置", @"消息中心", @"推荐给微信好友", @"设置", @"关于桃子旅行"]
#define loginCell                @"loginCell"
#define secondCell               @"secondCell"

@interface MineTableViewController ()

@end

@implementation MineTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoginTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loginCell];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 80.0;
    }
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loginCell forIndexPath:indexPath];
        return cell;
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:secondCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:secondCell];
        }
        cell.textLabel.text = [dataSource objectAtIndex:indexPath.row-1];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
            
        case 0: {
            LoginViewController *loginViewCtl = [[LoginViewController alloc] init];
            [self.navigationController pushViewController:loginViewCtl animated:YES];
        }
            break;
            
        case 1: {
            AccountManagerViewController *accountmanagerCtl = [[AccountManagerViewController alloc] init];
            [self.navigationController pushViewController:accountmanagerCtl animated:YES];
        }
            
            break;
            
        case 2: {
            
        }
            
            break;
            
        case 3:
            
            break;
            
        case 4:
            
            break;
            
        case 5:
            
            break;
            
        default:
            break;
    }
}

@end










