//
//  PTHomeViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/28/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTHomeViewController.h"
#import "MakePersonalTailorViewController.h"
#import "PTListTableViewCell.h"
#import "PersonalTailorViewController.h"
#import "PersonalTailorManager.h"

@interface PTHomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UILabel *ptNumberLabel;

@end

@implementation PTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_THEME_COLOR;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"PTListTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTListTableViewCell"];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];
    [self.view addSubview:_tableView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 250)];
    headerView.backgroundColor = APP_PAGE_COLOR;
    UIView *contentBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 240)];
    contentBg.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:contentBg];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 150)];
    titleLabel.backgroundColor = APP_THEME_COLOR;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"私人定制";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:40];
    [headerView addSubview:titleLabel];
    
    UIButton *makePTButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 160, kWindowWidth-60, 40)];
    makePTButton.layer.cornerRadius = 6;
    makePTButton.clipsToBounds = YES;
    makePTButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [makePTButton setBackgroundImage:[ConvertMethods createImageWithColor: APP_THEME_COLOR] forState:UIControlStateNormal];
    [makePTButton setTitle:@"发布定制需求" forState:UIControlStateNormal];
    [makePTButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [makePTButton addTarget:self action:@selector(makePT) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:makePTButton];
    
    UILabel *ptNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 210, kWindowWidth-24, 20)];
    ptNumberLabel.textColor = APP_THEME_COLOR;
    ptNumberLabel.font = [UIFont systemFontOfSize:15.0];
    ptNumberLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:ptNumberLabel];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (!_dataSource.count) {
        [PersonalTailorManager asyncLoadRecommendPersonalTailorData:^(BOOL isSuccess, NSArray<PTDetailModel *> *resultList) {
            if (isSuccess) {
                _dataSource = resultList;
                [self.tableView reloadData];
            }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count > 1) {     //如果是 push 的情况下才显示 navibar ，没想到更好的解决办法
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
- (void)makePT
{
    MakePersonalTailorViewController *ctl = [[MakePersonalTailorViewController alloc] init];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PTListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PTListTableViewCell" forIndexPath:indexPath];
    cell.ptDetailModel = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PersonalTailorViewController *ctl = [[PersonalTailorViewController alloc] init];
    ctl.ptDetailModel = [_dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:ctl animated:true];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_tableView]) {
        if (scrollView.contentOffset.y < 0) {
            scrollView.contentOffset = CGPointZero;
        }
    }
}
@end
