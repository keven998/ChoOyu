//
//  TZFrendListVC.m
//  TZCityDetail
//
//  Created by 冯宁 on 15/9/19.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "TZFrendListVC.h"

#import "TZFrendListCell.h"
#import "ARGUMENTSFORTZFrendList.h"
#import "Constants.h"
#import "GuiderProfileViewController.h"
#import "ExpertManager.h"
#import "TZProgressHUD.h"
#import "TZFrendListCellForArea.h"

#define CITYDETAILCELL @"CITYDETAILCELL"
#define CITYDETAILCELLFORAREA @"CITYDETAILCELLFORAREA"


@interface TZFrendListVC () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) NSArray* expertArray;
@property (nonatomic, strong) TZProgressHUD* hud;


@end

@implementation TZFrendListVC

- (instancetype)initWithCityName:(NSString*)cityName orAreaId:(NSString*)areaId{
    if (self = [super init]) {
        if (cityName != nil) {
            self.cityName = cityName;
            [self.tableView registerClass:[TZFrendListCell class] forCellReuseIdentifier:CITYDETAILCELL];
            [self loadFrendListOfCityData];
            self.title = [NSString stringWithFormat:@"全部达人"];
            return self;
        }
        self.areaId = areaId;
        [self.tableView registerClass:[TZFrendListCellForArea class] forCellReuseIdentifier:CITYDETAILCELLFORAREA];
        [self loadFrendListOfAreaData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareTableView];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_icon_navigation_back_hilighted"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)prepareTableView{
    
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:@{@"tableView":self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-|" options:0 metrics:nil views:@{@"tableView":self.tableView}]];
    
}

#pragma mark - 网络方法
- (void)loadFrendListOfCityData{
    //    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(self)weakSelf = self;
    //    [hud showHUDInViewController:weakSelf content:64];
    _hud = [[TZProgressHUD alloc] init];

    [_hud showHUDInViewController:weakSelf content:64];
    [ExpertManager asyncLoadExpertsWithAreaName:self.cityName page:0 pageSize:3 completionBlock:^(BOOL success, NSArray * result) {
        if (success) {
            self.expertArray = result;
            
            [weakSelf.tableView reloadData];
            [_hud hideTZHUD];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }else {

            [SVProgressHUD showHint:HTTP_FAILED_HINT];

            [_hud hideTZHUD];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];
}

- (void)loadFrendListOfAreaData{
    //    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(self)weakSelf = self;
    //    [hud showHUDInViewController:weakSelf content:64];
    _hud = [[TZProgressHUD alloc] init];
    
    [_hud showHUDInViewController:weakSelf content:64];
    [ExpertManager asyncLoadExpertsWithAreaId:self.areaId page:0 pageSize:10 completionBlock:^(BOOL isSuccess, NSArray *expertsArray) {
        if (isSuccess) {
            self.expertArray = expertsArray;
            
            [weakSelf.tableView reloadData];
            [_hud hideTZHUD];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }else {
            
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
            
            [_hud hideTZHUD];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];
}


#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.expertArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cityName != nil) {
        TZFrendListCell *cell = [tableView dequeueReusableCellWithIdentifier:CITYDETAILCELL forIndexPath:indexPath];
        //    cell.backgroundColor = RANDOMCOLOR;
        //    cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ExpertModel* model = self.expertArray[indexPath.section];
        cell.model = model;
        return cell;
    }
    TZFrendListCellForArea *cell = [tableView dequeueReusableCellWithIdentifier:CITYDETAILCELLFORAREA forIndexPath:indexPath];
    //    cell.backgroundColor = RANDOMCOLOR;
    //    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ExpertModel* model = self.expertArray[indexPath.section];
    cell.model = model;
    return cell;

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GuiderProfileViewController *guiderCtl = [[GuiderProfileViewController alloc] init];
    FrendModel *model = self.expertArray[indexPath.row];
    guiderCtl.userId = model.userId;
    guiderCtl.shouldShowExpertTipsView = YES;
    [self.navigationController pushViewController:guiderCtl animated:YES];
}
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

#pragma mark - setter & getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = APP_PAGE_COLOR;

//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//        _tableView.separatorEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark ];
    }
    return _tableView;
}
- (void)setAreaName:(NSString *)areaName{
    _areaName = areaName;
    self.title = [NSString stringWithFormat:@"~派派·%@·达人~",_areaName];
}

@end
