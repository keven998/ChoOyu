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
#define settingItems       @[@"清理缓存", @"意见和需求", @"给我们好评", @"消息和提醒"]

@interface SettingHomeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SettingHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat offsetY = 0;
    if (self.navigationController.navigationBarHidden) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 63.0)];
        bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:@"设置"];
        navTitle.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
        [bar pushNavigationItem:navTitle animated:YES];
        bar.shadowImage = [ConvertMethods createImageWithColor:APP_THEME_COLOR];
        [self.view addSubview:bar];
        offsetY = 64;
    } else {
        self.navigationItem.title = @"设置";
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, offsetY, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - offsetY) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorColor = APP_BORDER_COLOR;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:_tableView];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.titleView.text = [settingItems objectAtIndex:(indexPath.section * 2 + indexPath.row)];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end