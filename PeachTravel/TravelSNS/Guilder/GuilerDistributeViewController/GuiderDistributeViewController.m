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
#import "GuiderSearchViewController.h"
#import "GuiderProfileViewController.h"

@interface GuiderDistributeViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,HWDropdownMenuDelegate,dropDownMenuProtocol>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIButton *titleBtn;

// 总的数据源
@property (nonatomic, strong)NSMutableArray *dataSource;

// 每一个洲的达人列表
@property (nonatomic, strong)NSArray *guiderArray;

@property (nonatomic, strong)NSArray *titleArray;

/**
 *  新建一个字典存储展开的信息
 */
@property (nonatomic, strong)NSMutableDictionary * showDic;

@property (nonatomic, strong)HWDropdownMenu * dropDownMenu;
// 当前选中的大洲
@property (nonatomic) NSUInteger currentContinentIndex;

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
    
    UIImage *image = [UIImage imageNamed:@"expert_search"];
    // 返回一个没有渲染的图片给你
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 设置右上角的搜索按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(searchExpert:)];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = YES;
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
    
    UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.titleBtn = titleBtn;
    titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleBtn.selected = NO;
    [titleBtn setTitle:typeArray[0] forState:UIControlStateNormal];
    [titleBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [titleBtn addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchDown];
    [titleBtn setImage:[UIImage imageNamed:@"ArtboardBottom"] forState:UIControlStateNormal];
    [titleBtn setImage:[UIImage imageNamed:@"ArtboardTop"] forState:UIControlStateSelected];
    
    [self setupBtnFeature:titleBtn titleContent:typeArray[0]];
    
    titleBtn.frame = CGRectMake(kWindowWidth * 0.5, 0, kWindowWidth * 0.5, 50);
    self.navigationItem.titleView = titleBtn;
}

- (void)setupBtnFeature:(UIButton *)titleBtn titleContent:(NSString *)title
{
    CGSize size = CGSizeMake(kWindowWidth,CGFLOAT_MAX);
    NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0]};
    CGSize contentSize = [title boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    titleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, contentSize.width+40, 0, 0);
    titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
}

- (void)typeClick:(UIButton *)type
{
    NSLog(@"%s",__func__);
    
    type.selected = !type.selected;
    
    // 1.创建下拉菜单
    HWDropdownMenu *menu = [HWDropdownMenu menu];
    menu.delegate = self;
    menu.containerImage = @"bg_continent";
    self.dropDownMenu = menu;
    
    // 2.设置传入数组
    NSArray * siteArray = self.titleArray;
    
    // 3.设置内容
    DropDownViewController *vc = [[DropDownViewController alloc] init];
    vc.delegateDrop = self;
    vc.siteArray = siteArray;
    vc.showAccessory = self.currentContinentIndex;
    vc.tag = 3;
    vc.view.height = siteArray.count * 44;
    vc.view.width = kWindowWidth / 3;
    vc.tableView.scrollEnabled = NO;
    menu.contentController = vc;
    
    // 4.显示
    [menu showFrom:type];
}

/**
 *  搜索达人
 *
 *  @param sender 搜索达人
 */
- (void)searchExpert:(id)sender
{
    GuiderSearchViewController *searchCtl = [[GuiderSearchViewController alloc] init];
    
    searchCtl.hidesBottomBarWhenPushed = YES;
    [searchCtl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    TZNavigationViewController *tznavc = [[TZNavigationViewController alloc] initWithRootViewController:searchCtl];
    [self presentViewController:tznavc animated:YES completion:nil];
}

#pragma mark - 实现dropDownMenuProtocol代理方法
- (void)didSelectedContinentIndex:(NSInteger)continentIndex
{
    self.currentContinentIndex = continentIndex;
    [self.dropDownMenu dismiss];
    
    [self.titleBtn setTitle:self.titleArray[continentIndex] forState:UIControlStateNormal];
    [self setupBtnFeature:self.titleBtn titleContent:self.titleArray[continentIndex]];
    
    self.guiderArray = self.dataSource[continentIndex];
    
    [self.tableView reloadData];
}

#pragma mark - HWDropdownMenuDelegate
/**
 *  下拉菜单被销毁了
 */
- (void)dropdownMenuDidDismiss:(HWDropdownMenu *)menu
{
    self.titleBtn.selected = NO;
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
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.guiderArray.count;
}

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
    GuiderDistribute * guiderDistribute = _guiderArray[indexPath.row];
    
    // 这里传入的distributionArea应该是该地区的区域ID
    guiderCtl.distributionArea = guiderDistribute.ID;
    guiderCtl.guiderDistribute = guiderDistribute;
    guiderCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:guiderCtl animated:YES];
     
}

@end
