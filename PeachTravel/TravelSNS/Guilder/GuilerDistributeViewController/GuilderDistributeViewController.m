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
#import "GuilderDistributeContinent.h"
@interface GuilderDistributeViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong)NSArray * guiderArray;

@property (nonatomic, strong)NSMutableArray * dataSource;

@property (nonatomic, strong)NSArray * titleArray;

/**
 *  新建一个字典存储展开的信息
 */
@property (nonatomic, strong)NSMutableDictionary * showDic;

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
    NSString * url = API_GET_TOUR_GULIDER;
    
    NSLog(@"%@",url);
    
    // 3.发送Get请求
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@",responseObject);
        /**
         *  获取字典数组
         */
        NSArray * resultArray = responseObject[@"result"];
        
        /**
         *  将字典数组转换成模型数组
         */
        self.guiderArray = [GuilderDistribute objectArrayWithKeyValuesArray:resultArray];
        [self revertGuiderListToGroup:self.guiderArray];
        
        NSLog(@"%@",self.guiderArray);
        
        // 获得数据后刷新表格
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 打印失败信息
        NSLog(@"%@",error);
    }];
    
}

// 处理guiderArray数组,将一个数组转换成分组数组

- (void)revertGuiderListToGroup:(NSArray *)guiderList
{
    // 1.创建一个分组数组,里面存放了多少组数据
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.titleArray.count; i++) {
        
        NSMutableArray * array = [NSMutableArray array];
        [dataSource addObject:array];
    }
    self.dataSource = dataSource;
    
    // 2.遍历数组
    for (GuilderDistribute * distrubute in guiderList) {
        int i = 0;
        GuilderDistributeContinent * guilderContinent = distrubute.continents;
        for (NSString * title in _titleArray)
        {
            if ([guilderContinent.zhName isEqualToString:title]) {
                NSMutableArray *array = dataSource[i];
                [array addObject:distrubute];
                break;
            }
            i++;
        }
    }
    
    // 3.过滤数组为空的元素
    for (int i = 0; i < self.dataSource.count; i++) {
        NSArray * guilderArray = self.dataSource[i];
        if (guilderArray.count == 0) {
            [self.dataSource removeObject:guilderArray];
        }
    }
}


// 懒加载tableView
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerNib:[UINib nibWithNibName:@"GuiderCell" bundle:nil]  forCellReuseIdentifier:@"GuiderCell"];
        
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![_showDic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.section]]) {
        return 232*CGRectGetWidth(self.view.frame)/414;
    }
    return 0;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.dataSource.count;
    //    return 5;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * guilderArray = self.dataSource[section];
    return guilderArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

// 返回每一组的头部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    view.tag = section;
    view.backgroundColor = [UIColor whiteColor];
    UILabel *sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, CGRectGetWidth(self.view.bounds), 38)];
    
    
    // 设置头像的标题
    sectionLabel.text = self.titleArray[section];
    
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    sectionLabel.textColor = APP_THEME_COLOR;
    sectionLabel.font = [UIFont boldSystemFontOfSize:14];
    sectionLabel.tag = 1;
    [view addSubview:sectionLabel];
    
    // 添加手势监听,对于手势事件的,点击cell进行展开
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1; //点击的次数 =1:单击
    [singleRecognizer setNumberOfTouchesRequired:1];//1个手指操作
    [view addGestureRecognizer:singleRecognizer];//添加一个手势监测；
    
    return view;
}

#pragma mark 展开收缩section中cell 手势监听
-(void)SingleTap:(UITapGestureRecognizer*)recognizer{
    
    NSLog(@"%s",__func__);
    
    NSInteger didSection = recognizer.view.tag;
    
    if (!_showDic) {
        _showDic = [[NSMutableDictionary alloc]init];
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld",didSection];
    if (![_showDic objectForKey:key]) {
        [_showDic setObject:@"1" forKey:key];
        
    }else{
        [_showDic removeObjectForKey:key];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:didSection] withRowAnimation:UITableViewRowAnimationFade];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // cell的初始化
    GuiderCell * cell = [GuiderCell guiderWithTableView:tableView];
    
    cell.guiderDistribute = _dataSource[indexPath.section][indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.separatorInset=UIEdgeInsetsZero;
    cell.clipsToBounds = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuiderCollectionViewController *guider = [[GuiderCollectionViewController alloc] initWithNibName:@"GuiderCollectionViewController" bundle:nil];
    GuilderDistribute * guilderDistribute = _dataSource[indexPath.section][indexPath.row];
    
    // 这里传入的distributionArea应该是该地区的区域ID
    guider.distributionArea = guilderDistribute.ID;
    guider.guiderDistribute = guilderDistribute;
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
