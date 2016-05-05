//
//  PTListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on kPageCount/28/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTListViewController.h"
#import "MakePersonalTailorViewController.h"
#import "PTListTableViewCell.h"
#import "PersonalTailorViewController.h"
#import "PersonalTailorManager.h"
#import "MJRefresh.h"


#define kPageCount 10

@interface PTListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<PTDetailModel *> *dataSource;
@property (nonatomic, strong) UILabel *ptNumberLabel;

@end

@implementation PTListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_THEME_COLOR;
    _dataSource = [[NSMutableArray alloc] init];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"PTListTableViewCell" bundle:nil] forCellReuseIdentifier:@"PTListTableViewCell"];
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];

    [self.view addSubview:_tableView];
    
    if (_isLoadSellerPTData) {
        self.navigationItem.title = @"服务列表";
        [PersonalTailorManager asyncLoadSellerServerPTDataWithUserId:_userId index:0 pageCount:kPageCount completionBlock:^(BOOL isSuccess, NSArray<PTDetailModel *> *resultList) {
            if (isSuccess) {
                [_dataSource addObjectsFromArray:resultList];
                [self.tableView reloadData];
            }
        }];
    } else {
        self.navigationItem.title = @"需求列表";

        [PersonalTailorManager asyncLoadUsrePTDataWithUserId:_userId index:0 pageCount:kPageCount completionBlock:^(BOOL isSuccess, NSArray<PTDetailModel *> *resultList) {
            if (isSuccess) {
                [_dataSource addObjectsFromArray:resultList];
                [self.tableView reloadData];
            }
        }];
        
    }
}

- (void)loadMoreData
{
    if (_isLoadSellerPTData) {
        self.navigationItem.title = @"服务列表";
        
        [PersonalTailorManager asyncLoadSellerServerPTDataWithUserId:_userId index:[_dataSource count] pageCount:kPageCount completionBlock:^(BOOL isSuccess, NSArray<PTDetailModel *> *resultList) {
            [_tableView.footer endRefreshing];
            if (isSuccess) {
                [_dataSource addObjectsFromArray:resultList];
                [self.tableView reloadData];
            }
        }];
    } else {
        self.navigationItem.title = @"需求列表";
        
        [PersonalTailorManager asyncLoadUsrePTDataWithUserId:_userId index:[_dataSource count] pageCount:kPageCount completionBlock:^(BOOL isSuccess, NSArray<PTDetailModel *> *resultList) {
            [_tableView.footer endRefreshing];
            if (isSuccess) {
                [_dataSource addObjectsFromArray:resultList];
                [self.tableView reloadData];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
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
    ctl.ptId = [_dataSource objectAtIndex:indexPath.row].itemId;
    [self.navigationController pushViewController:ctl animated:true];
}

@end
