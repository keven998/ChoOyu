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
#import "MJRefresh.h"

@interface PTHomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UILabel *ptNumberLabel;

@end

@implementation PTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight-49) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView registerNib:[UINib nibWithNibName:@"PTListTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTListTableViewCell"];
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
    _tableView.tableHeaderView = headerView;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.tableView.header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    
    [PersonalTailorManager asyncLoadRecommendPersonalTailorDataWithStartIndex:_dataSource.count pageCount:15 completionBlock:^(BOOL isSuccess, NSArray<PTDetailModel *> *resultList) {
        if (isSuccess) {
            _dataSource = resultList;
            [self.tableView reloadData];
        }
    }];
    
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count > 1) {     //如果是 push 的情况下才显示 navibar ，没想到更好的解决办法
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)refreshData
{
    [PersonalTailorManager asyncLoadRecommendPersonalTailorDataWithStartIndex:0 pageCount:15 completionBlock:^(BOOL isSuccess, NSArray<PTDetailModel *> *resultList) {
        if (isSuccess) {
            _dataSource = resultList;
            [self.tableView reloadData];
        }
    }];
  
    [_tableView.header endRefreshing];
}

- (void)loadMoreData
{
    [_tableView.footer endRefreshing];
    [PersonalTailorManager asyncLoadRecommendPersonalTailorDataWithStartIndex:_dataSource.count pageCount:15 completionBlock:^(BOOL isSuccess, NSArray<PTDetailModel *> *resultList) {
        if (isSuccess) {
            
            NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:_dataSource];
            [temp addObjectsFromArray:resultList];
            _dataSource = temp;
            [self.tableView reloadData];
        }
    }];

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
//            scrollView.contentOffset = CGPointZero;
        }
    }
}
@end
