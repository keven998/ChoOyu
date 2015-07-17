//
//  GuilderDistributeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/23.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuilderDistributeViewController.h"
#import "GuiderCollectionViewController.h"
#import "GuiderCell.h"
#import "GuilderDistribute.h"
#import "MJExtension.h"
@interface GuilderDistributeViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong)NSArray * guiderArray;

@property (nonatomic, strong)NSMutableArray * dataSource;

@property (nonatomic, strong)NSArray * titleArray;

@end

@implementation GuilderDistributeViewController

/**
 *  懒加载模型数组
 */
- (NSArray *)guiderArray
{
    if (_guiderArray == nil) {
        _guiderArray = [NSArray array];
    }
    return _guiderArray;
}

/**
 *  懒加载分组总数组,里面包含每组的数组数据
 */
- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

/**
 *  初始化标题数组
 */
- (NSArray *)titleArray
{
    if (_titleArray == nil) {
        _titleArray = @[@"亚洲",@"欧洲",@"美洲",@"大洋洲",@"非洲"];
    }
    return _titleArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"派派达人";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    [self.view addSubview:self.tableView];
    
    // 发送网络请求
    [self sendRequest];
}

#pragma mark - 请求网络数据
- (void)sendRequest
{
    // 1.获取请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // 2.请求链接
    NSString * url = @"http://api-dev.lvxingpai.com/app/geo/countrys";
    
    // 3.发送Get请求
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        /**
         *  获取字典数组
         */
        NSArray * resultArray = responseObject[@"result"];
        
        /**
         *  将字典数组转换成模型数组
         */
        self.guiderArray = [GuilderDistribute objectArrayWithKeyValuesArray:resultArray];
        
        // 获得数据后刷新表格
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 打印失败信息
        NSLog(@"%@",error);
    }];
    
}

// 处理guiderArray数组,将一个数组转换成分组数组
/*
- (NSArray *)revertGuiderListToGroup:(NSArray *)guiderList
{
    // 1.创建一个分组数组,里面存放了多少组数据
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.titleArray.count; i++) {
        
        NSMutableArray * array = [NSMutableArray array];
        [dataSource addObject:array];
    }
    
    self.dataSource = dataSource;
    
    // 2.遍历数组
    for (ShoppingPoi * poi in shoppingList) {
        CityDestinationPoi * cityPoi = poi.locality;
        int i = 0;
        for (CityDestinationPoi * destpoi in _tripDetail.destinations)
        {
            if ([cityPoi.cityId isEqualToString:destpoi.cityId]) {
                NSMutableArray *array = dataSource[i];
                [array addObject:poi];
                break;
            }
            i++;
        }
    }
    
    return dataSource;
}
 */

// 懒加载tableView
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerNib:[UINib nibWithNibName:@"GuiderCell" bundle:nil]  forCellReuseIdentifier:@"GuiderCell"];
        
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 232*CGRectGetWidth(self.view.frame)/414;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.guiderArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

// 返回每一组的头部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, CGRectGetWidth(self.view.bounds), 38)];

    // 设置头像的标题
    sectionLabel.text = self.titleArray[section];
    
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    sectionLabel.textColor = APP_THEME_COLOR;
    sectionLabel.font = [UIFont systemFontOfSize:12];
    sectionLabel.tag = 1;
    [view addSubview:sectionLabel];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // cell的初始化
    GuiderCell * cell = [GuiderCell guiderWithTableView:tableView];
    cell.guiderDistribute = self.guiderArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuiderCollectionViewController *guider = [[GuiderCollectionViewController alloc] initWithNibName:@"GuiderCollectionViewController" bundle:nil];
    GuilderDistribute * guilderDistribute = self.guiderArray[indexPath.row];
    guider.distributionArea = guilderDistribute.zhName;
    guider.guiderDistribute = self.guiderArray[indexPath.row];
    [self.navigationController pushViewController:guider animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 44;
    CGPoint point;
    NSIndexPath *indexPath;
    point = scrollView.contentOffset;
    indexPath = [_tableView indexPathForRowAtPoint:point];
    if (indexPath.section == 0) {
        self.title = @"亚洲";
    } else if (indexPath.section == 1) {
        self.title = @"欧洲";
    } else if (indexPath.section == 2) {
        self.title = @"美洲";
    } else if (indexPath.section == 3) {
        self.title = @"大洋洲";
    } else if (indexPath.section == 4) {
        self.title = @"非洲";
    }
    
    if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        
    }
    else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
