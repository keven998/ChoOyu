//
//  PushSettingViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/11/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "PushSettingViewController.h"
#import "PushSettingTableViewCell.h"

@interface PushSettingViewController ()

@property (nonatomic) BOOL isNoDisturbing;

@end

@implementation PushSettingViewController

/*
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"消息和提醒";
    [self.tableView registerNib:[UINib nibWithNibName:@"PushSettingTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"push_cell"];
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    (options.noDisturbStatus == ePushNotificationNoDisturbStatusDay) ? (_isNoDisturbing = YES) : (_isNoDisturbing = NO);
//    _isNoDisturbing = options.noDisturbing;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma UITableViewDataSourcex

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PushSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"push_cell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.titleView.text = @"贴心旅行相关推送";
        [cell.switchButton removeTarget:self action:@selector(enablePush:) forControlEvents:UIControlEventValueChanged];
        [cell.switchButton addTarget:self action:@selector(enablePush:) forControlEvents:UIControlEventValueChanged];
    } else if (indexPath.row == 1) {
        cell.titleView.text = @"消息提醒";
        [cell.switchButton removeTarget:self action:@selector(enableCircleMsg:) forControlEvents:UIControlEventValueChanged];
        [cell.switchButton addTarget:self action:@selector(enableCircleMsg:) forControlEvents:UIControlEventValueChanged];
        cell.switchButton.on = !_isNoDisturbing;
    }
    return cell;
}

#pragma UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        
    } else {
        
    }
}

#pragma IBAction
-(void)enablePush:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL on = [switchButton isOn];
    if (on) {
        
    } else {
        
    }
}

-(void)enableCircleMsg:(id)sender {
    _isNoDisturbing = !_isNoDisturbing;
    [self savePushOptions];
}


- (void)savePushOptions
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    if (_isNoDisturbing) {
        options.noDisturbStatus = ePushNotificationNoDisturbStatusDay;
    } else {
        options.noDisturbStatus = ePushNotificationNoDisturbStatusClose;
    }
    
    [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:^(EMPushNotificationOptions *options, EMError *error) {
        if (!error) {
//                [SVProgressHUD showHint:@"设置成功"];
        } else {
            [SVProgressHUD showHint:@"设置失败"];
            _isNoDisturbing = !_isNoDisturbing;
            [self.tableView reloadData];
        }
    } onQueue:nil];
}
*/

@end
