//
//  SpotDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotDetailViewController.h"
#import "SpotDetailView.h"
#import "SpotPoi.h"
#import "ChatRecoredListTableViewController.h"
#import "CreateConversationViewController.h"

@interface SpotDetailViewController () <CreateConversationDelegate>

@property (nonatomic, strong) SpotPoi *spotPoi;
@property (nonatomic, strong) UIButton *rightItemBtn;
@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;

@end

@implementation SpotDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _rightItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_rightItemBtn setTitle:@"chat" forState:UIControlStateNormal];
    [_rightItemBtn setTitleColor:UIColorFromRGB(0xee528c) forState:UIControlStateNormal];
    [_rightItemBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightItemBtn];
    [self loadData];
}

- (void)updateView
{
    SpotDetailView *spotDetailView = [[SpotDetailView alloc] initWithFrame:self.view.frame];
    spotDetailView.spot = self.spotPoi;
    [self.view addSubview:spotDetailView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - IBAction Methods

- (IBAction)chat:(id)sender
{
    _chatRecordListCtl = [[ChatRecoredListTableViewController alloc] init];
    _chatRecordListCtl.delegate = self;
    UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:_chatRecordListCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

#pragma mark - Private Methods

- (void) loadData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@5474674fd174911938325828", API_GET_SPOT_DETAIL];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取景点详情数据****\n%@", responseObject);
        if (result == 0) {
            [SVProgressHUD dismiss];
            _spotPoi = [[SpotPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [SVProgressHUD showErrorWithStatus:@"无法获取数据"];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [SVProgressHUD showErrorWithStatus:@"无法获取数据"];
    }];

    
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup chatTitle:(NSString *)chatTitle
{
    [_chatRecordListCtl dismissViewControllerAnimated:YES completion:^{
        ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:chatter isGroup:isGroup];
        chatCtl.title = chatTitle;
        [self.navigationController pushViewController:chatCtl animated:YES];
    }];
}
@end




