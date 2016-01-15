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
#import "ExpertRequestViewController.h"
#import "SuperWebViewController.h"
#import "iRate.h"
#import "UMSocial.h"

#define cellIdentifier   @"settingCell"
#define SET_ITEMS       @[@[@"推荐应用给朋友", @"申请成为商家"], @[@"清理缓存", @"应用评分"],@[@"意见反馈", @"关于我们"]]

@interface SettingHomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footerView;

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
    _tableView.tableFooterView = self.footerView;
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

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 72)];
        
        UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(12.0, 20.0, self.view.bounds.size.width - 24.0, 52.0)];
        logoutBtn.center = _footerView.center;
        logoutBtn.layer.cornerRadius = 4.0;
        logoutBtn.clipsToBounds = YES;
        [logoutBtn setBackgroundImage:[[UIImage imageNamed:@"chat_drawer_leave.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
        
        logoutBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        logoutBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        logoutBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [logoutBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:logoutBtn];
        
    }
    return _footerView;
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

- (void)shareToWeChat
{
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"推荐\"旅行派\"给你。";
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://www.lvxingpai.com/app/download/";
    
    UIImage *shareImage = [UIImage imageNamed:@"share_icon.png"];
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:@"汇聚全球特色旅游体验项目的应用" image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
    }];
}

#pragma mark - IBAction Methods

/**
 *  退出登录
 *
 *  @param sender
 */
-(IBAction)logout:(id)sender
{
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                  message:@"确定退出旅行派登录"
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SET_ITEMS.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[SET_ITEMS objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.titleView.text = [[SET_ITEMS objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.flagView.image = [UIImage imageNamed:@"ic_setting_cache_clean.png"];
            NSString *str = [NSString stringWithFormat:@"%.2fM",(float)[[SDImageCache sharedImageCache] getSize]/(1024*1024)];
            cell.cacheLabel.text = str;
            cell.cacheLabel.tag = 101;
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self shareToWeChat];
        } else if (indexPath.row == 1) {
            ExpertRequestViewController *ctl = [[ExpertRequestViewController alloc] init];
            [self.navigationController pushViewController:ctl animated:YES];
        }
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self clearMemo];

        } else if (indexPath.row == 1) {
            [self mark];
        }
        
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            FeedbackController *feedbackCtl = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedbackCtl animated:YES];
            
        } else if (indexPath.row == 1) {
            SuperWebViewController *aboutMeCtl = [[SuperWebViewController alloc] init];
            aboutMeCtl.titleStr = @"关于我们";
            aboutMeCtl.urlStr = APP_ABOUT;
            [self.navigationController pushViewController:aboutMeCtl animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [SVProgressHUD show];
        [accountManager asyncLogout:^(BOOL isSuccess) {
            if (isSuccess) {
                [self showHint:@"退出成功"];
                [self.navigationController popViewControllerAnimated:YES];

            } else {
                [self showHint:@"退出失败"];
            }
        }];
    }
}


@end
