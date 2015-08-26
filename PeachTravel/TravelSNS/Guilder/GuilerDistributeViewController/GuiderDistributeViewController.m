//
//  GuiderDistributeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/23.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuiderDistributeViewController.h"
#import "GuiderCollectionViewController.h"
#import "GuiderCell.h"
#import "GuiderDistribute.h"
#import "MJExtension.h"
#import "GuiderDistributeContinent.h"
#import "GuiderDistributeTools.h"
#import "HWDropdownMenu.h"
#import "DropDownViewController.h"

@interface GuiderDistributeViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,HWDropdownMenuDelegate,dropDownMenuProtocol>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIButton *titleBtn;

// 总的数据源
@property (nonatomic, strong)NSMutableArray *dataSource;

// 每一个洲的达人列表
@property (nonatomic, strong)NSArray *guiderArray;

@property (nonatomic, strong)NSArray * titleArray;

/**
 *  新建一个字典存储展开的信息
 */
@property (nonatomic, strong)NSMutableDictionary * showDic;

@property (nonatomic, strong)HWDropdownMenu * dropDownMenu;

@end

@implementation GuiderDistributeViewController


/**
 *  懒加载分组总数组,里面包含每组的数组数据
 */
- (NSArray *)guiderArray
{
    if (_guiderArray == nil) {
        _guiderArray = [NSArray array];
    }
    return _guiderArray;
}

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
        _titleArray = [GuiderDistributeTools getTitleArray];
    }
    return _titleArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"派派达人";
    
    [self.view addSubview:self.tableView];
    
    // 发送网络请求
    [self setupStatus];
    
    // 设置头部标题的格式
    [self setupHeaderTitle];
    
    [self.navigationController.navigationBar setBackgroundColor:APP_PAGE_COLOR];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_lxp_guide_distribute"];
  
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_lxp_guide_distribute"];
  
}

#pragma mark - 获得达人数据
- (void)setupStatus {
    
    [GuiderDistributeTools guiderStatusWithParam:nil success:^(NSArray *dataSource) {
        [self.dataSource addObjectsFromArray:dataSource];
        self.guiderArray = [self.dataSource firstObject];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

// 设置头部标题页面
- (void)setupHeaderTitle
{
    // 设置分类界面的一些基本属性
    NSArray * typeArray = self.titleArray;
    
    UIButton * type = [UIButton buttonWithType:UIButtonTypeCustom];
    self.titleBtn = type;
    type.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    type.selected = NO;
    [type setTitle:typeArray[0] forState:UIControlStateNormal];
    [type setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [type addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchDown];
    [type setImage:[UIImage imageNamed:@"ArtboardBottom"] forState:UIControlStateNormal];
    [type setImage:[UIImage imageNamed:@"ArtboardTop"] forState:UIControlStateSelected];
    type.imageEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    type.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
    type.frame = CGRectMake(kWindowWidth * 0.5, 0, kWindowWidth * 0.5, 50);
    self.navigationItem.titleView = type;
}

- (void)typeClick:(UIButton *)type
{
    NSLog(@"%s",__func__);
    
    type.selected = !type.selected;
    
    // 1.创建下拉菜单
    HWDropdownMenu *menu = [HWDropdownMenu menu];
    menu.delegate = self;
    self.dropDownMenu = menu;
    
    // 2.设置传入数组
    NSArray * siteArray = self.titleArray;
    
    // 3.设置内容
    DropDownViewController *vc = [[DropDownViewController alloc] init];
    vc.delegateDrop = self;
    vc.siteArray = siteArray;
//    vc.showAccessory = _currentListTypeIndex;
    vc.tag = 3;
    vc.view.height = siteArray.count * 44;
    vc.view.width = kWindowWidth / 3;
    vc.tableView.scrollEnabled = NO;
    menu.contentController = vc;
    
    // 4.显示
    [menu showFrom:type];
}

#pragma mark - 实现dropDownMenuProtocol代理方法
- (void)didSelectedContinentIndex:(NSInteger)continentIndex
{
    [self.dropDownMenu dismiss];
    [self.titleBtn setTitle:self.titleArray[continentIndex] forState:UIControlStateNormal];
    self.guiderArray = self.dataSource[continentIndex];
    
    NSLog(@"%@",self.guiderArray);
    [self.tableView reloadData];
}

#pragma mark - HWDropdownMenuDelegate
/**
 *  下拉菜单被销毁了
 */
- (void)dropdownMenuDidDismiss:(HWDropdownMenu *)menu
{
//    self.cityButton.selected = NO;
//    self.categoryButton.selected = NO;
    // 让箭头向下
    //    [titleButton setImage:[UIImage imageNamed:@"navigationbar_arrow_down"] forState:UIControlStateNormal];
}

/**
 *  下拉菜单显示了
 */
- (void)dropdownMenuDidShow:(HWDropdownMenu *)menu
{
    
}

// 懒加载tableView
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerNib:[UINib nibWithNibName:@"GuiderCell" bundle:nil]  forCellReuseIdentifier:@"GuiderCell"];
        
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (![_showDic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.section]]) {
        return 232*CGRectGetWidth(self.view.frame)/414;
    }
    return 0;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
//    return self.dataSource.count;
    return 1;
    //    return 5;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.guiderArray.count;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

// 返回每一组的头部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton *headerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    headerBtn.tag = section;
    [headerBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [headerBtn setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateHighlighted];
    headerBtn.layer.borderWidth = 0.5;
    headerBtn.layer.borderColor = APP_PAGE_COLOR.CGColor;
    [headerBtn setTitle:self.titleArray[section] forState:UIControlStateNormal];
    [headerBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    headerBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    headerBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    [headerBtn addTarget:self action:@selector(singleTap:) forControlEvents:UIControlEventTouchUpInside];

    return headerBtn;
}
 */

#pragma mark 展开收缩section中cell 手势监听
-(void)singleTap:(UIButton*)recognizer
{
    NSInteger didSection = recognizer.tag;
    
    if (!_showDic) {
        _showDic = [[NSMutableDictionary alloc]init];
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld",didSection];
    if (![_showDic objectForKey:key]) {
        [_showDic setObject:@"1" forKey:key];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:didSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [_showDic removeObjectForKey:key];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:didSection] withRowAnimation:UITableViewRowAnimationAutomatic];
        if ([_dataSource[didSection] count] > 0) {
            [self performSelector:@selector(scrollToVisiable:) withObject:[NSNumber numberWithLong:didSection] afterDelay:0.35];
        }
    }
}

- (void)scrollToVisiable:(NSNumber *)section
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[section intValue]]
                         atScrollPosition:UITableViewScrollPositionNone animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // cell的初始化
    GuiderCell * cell = [GuiderCell guiderWithTableView:tableView];
    cell.guiderDistribute = self.guiderArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset=UIEdgeInsetsZero;
    cell.clipsToBounds = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuiderCollectionViewController *guiderCtl = [[GuiderCollectionViewController alloc] initWithNibName:@"GuiderCollectionViewController" bundle:nil];
    GuiderDistribute * guiderDistribute = _dataSource[indexPath.section][indexPath.row];
    
    // 这里传入的distributionArea应该是该地区的区域ID
    guiderCtl.distributionArea = guiderDistribute.ID;
    guiderCtl.guiderDistribute = guiderDistribute;
    guiderCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:guiderCtl animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 44;
    CGPoint point;
    NSIndexPath *indexPath;
    point = scrollView.contentOffset;
    indexPath = [_tableView indexPathForRowAtPoint:point];
    if (indexPath.section == 0) {
        self.navigationItem.title = @"亚洲";
    } else if (indexPath.section == 1) {
        self.navigationItem.title = @"欧洲";
    } else if (indexPath.section == 2) {
        self.navigationItem.title = @"美洲";
    } else if (indexPath.section == 3) {
        self.navigationItem.title = @"大洋洲";
    } else if (indexPath.section == 4) {
        self.navigationItem.title = @"非洲";
    }
    
    if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
