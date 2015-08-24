//
//  SettingHomeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/9.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "SettingHomeViewController.h"
#import "FeedbackViewController.h"
#import "OptionTableViewCell.h"
#import "PushSettingViewController.h"
#import "iRate.h"

#define cellIdentifier   @"settingCell"
#define SET_ITEMS       @[@"清理缓存", @"应用评分", @"消息和提醒"]

@interface SettingHomeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SettingHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.separatorColor = COLOR_LINE;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:_tableView];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"page_app_setting"];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"page_app_setting"];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods

/**
 *  评分
 */
- (IBAction)mark
{
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    [iRate sharedInstance].previewMode = NO;
    [iRate sharedInstance].appStoreID = APP_ID.intValue;
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (void)clearMemo
{
    [SVProgressHUD show];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showHint:@"清理完成"];
            UILabel *label = (UILabel*)[self.view viewWithTag:101];
            label.text = @"0M";
        });
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64*kWindowHeight/736;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    return [dataSource count]/2;
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleView.text = [SET_ITEMS objectAtIndex:(indexPath.section * 2 + indexPath.row)];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.flagView.image = [UIImage imageNamed:@"ic_setting_cache_clean.png"];
            NSString *str = [NSString stringWithFormat:@"%.2fM",(float)[[SDImageCache sharedImageCache] getSize]/(1024*1024)];
            cell.cacheLabel.text = str;
            cell.cacheLabel.tag = 101;
        } else if (indexPath.row == 1) {
            cell.flagView.image = [UIImage imageNamed:@"ic_setting_apprise.png"];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.flagView.image = [UIImage imageNamed:@"ic_good"];
        } else if (indexPath.row == 1) {
            cell.flagView.image = [UIImage imageNamed:@"ic_app_message.png"];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.section*2 + indexPath.row;
    switch (index) {
        case 0:
            [self clearMemo];
            break;
            
        case 1:
            [self mark];
            break;
            
        case 2: {
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
