//
//  SettingTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "SettingTableViewController.h"
#import "FeedbackViewController.h"
#import "OptionTableViewCell.h"
#import "PushSettingViewController.h"

#define cellIdentifier   @"settingCell"
#define dataSource       @[@"清理缓存", @"我有意见", @"去App Store评分", @"消息和提醒"]

@interface SettingTableViewController ()

@end

@implementation SettingTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
}

#pragma mark - private methods

- (void)mark {
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = APP_PAGE_COLOR;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count]/2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.titleView.text = [dataSource objectAtIndex:(indexPath.section * 2 + indexPath.row)];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.flagView.image = [UIImage imageNamed:@"ic_clear_cache.png"];
        } else if (indexPath.row == 1) {
            cell.flagView.image = [UIImage imageNamed:@"ic_feedback.png"];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.flagView.image = [UIImage imageNamed:@"ic_score_app.png"];
        } else if (indexPath.row == 1) {
            cell.flagView.image = [UIImage imageNamed:@"ic_app_message.png"];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.section*2 + indexPath.row;
    switch (index) {
        case 0: {
            
        }
            break;
            
        case 1: {
            FeedbackController *feedbackCtl = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedbackCtl animated:YES];
        }
            break;
            
        case 2:
            [self mark];
            break;
            
        case 3: {
            PushSettingViewController *ctl = [[PushSettingViewController alloc] init];
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end


