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
#import "iRate.h"

#define cellIdentifier   @"settingCell"
#define dataSource       @[@"清理缓存", @"意见与吐槽", @"去App Store评分", @"消息和提醒"]

@interface SettingTableViewController ()

@end

@implementation SettingTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorColor = APP_BORDER_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_app_setting"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_app_setting"];
}

#pragma mark - private methods

/**
 *  评分
 */
- (IBAction)mark
{
    [MobClick event:@"event_rates_app"];
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    [iRate sharedInstance].previewMode = NO;
    [iRate sharedInstance].appStoreID = APP_ID.intValue;
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (void)clearMemo
{
    [SVProgressHUD show];
    [MobClick event:@"event_clear_cache"];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showHint:@"已清理"];
        });
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = APP_PAGE_COLOR;
//    return view;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [dataSource count]/2;
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleView.text = [dataSource objectAtIndex:(indexPath.section * 2 + indexPath.row)];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.flagView.image = [UIImage imageNamed:@"ic_clear_cache.png"];
            cell.extender.image = nil;
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
    NSInteger index = indexPath.section*2 + indexPath.row;
    switch (index) {
        case 0: {
            [self clearMemo];
        }
            break;
            
        case 1: {
            [MobClick event:@"event_feedback"];
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


