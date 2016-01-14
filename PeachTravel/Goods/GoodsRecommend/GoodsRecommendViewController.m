//
//  GoodsRecommendViewController.m/Users/liangpengshuai/Documents/IDo
//  PeachTravel
//
//  Created by liangpengshuai on 10/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsRecommendViewController.h"
#import "GoodsRecommendTableViewCell.h"
#import "GoodsRecommendHeaderView.h"
#import "GoodsRecommendSectionHeaderView.h"
#import "GoodsDetailViewController.h"
#import "CityDetailViewController.h"
#import "MakeOrderViewController.h"
#import "GoodsManager.h"
#import "TZSchemeManager.h"
#import "NSURL+TZURL.h"
#import "ErrorEmptyView.h"

@interface GoodsRecommendViewController ()<UITableViewDataSource, UITableViewDelegate, GoodsRecommendHeaderViewDelegate, ErrorEmptyViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *scroll2TopBtn;
@property (nonatomic, strong) GoodsRecommendHeaderView *headerView;
@property (nonatomic, strong) UIView *navigationBar;
@property (nonatomic, strong) ErrorEmptyView *errorView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *recommendDataSource;   //顶部运营位

@end

@implementation GoodsRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    NSLog(@"%@", self.navigationController);

    [_tableView registerNib:[UINib nibWithNibName:@"GoodsRecommendTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsRecommendCell"];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _headerView = [[GoodsRecommendHeaderView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 335)];
    _tableView.tableHeaderView = _headerView;
    _headerView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 49)];
    _scroll2TopBtn.hidden = YES;
    [_scroll2TopBtn addTarget:self action:@selector(scroll2Top) forControlEvents:UIControlEventTouchUpInside];
    [self setNavigationBar];
    [self loadData];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadData
{
    if (_errorView) {
        [_errorView removeFromSuperview];
        _errorView = nil;
    }
    [GoodsManager asyncLoadRecommendGoodsWithCompletionBlock:^(BOOL isSuccess, NSArray<NSDictionary *> *goodsList) {
        if (isSuccess) {
            
            NSString *url = [NSString stringWithFormat:@"%@columns", BASE_URL];
            [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                if (code == 0) {
                    _headerView.recommendData = [responseObject objectForKey:@"result"];
                    _dataSource = goodsList;
                    [self.tableView reloadData];
                    _navigationBar.alpha = 0;
                    
                } else {
                    [self setupErrorEmptyView];
                }
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        } else {
            [self setupErrorEmptyView];
        }
    }];
}

- (void)setupErrorEmptyView
{
    if (_errorView) {
        [_errorView removeFromSuperview];
        _errorView = nil;
    }
    _errorView = [[ErrorEmptyView alloc] initWithFrame:CGRectMake(0, 84, kWindowWidth, 300)];
    _errorView.delegate = self;
    [self.view addSubview:_errorView];
    _navigationBar.alpha = 1;
}

- (void)setNavigationBar
{
    _navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 64)];
    _navigationBar.backgroundColor = APP_NAVIGATIONBAR_NOALPHA;
    _navigationBar.alpha = 0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, kWindowWidth, 44)];
    titleLabel.text = @"旅行派";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_navigationBar addSubview:titleLabel];
    [self.view addSubview:_navigationBar];
}

- (void)scroll2Top
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic = [_dataSource objectAtIndex:section];
    return [[dic objectForKey:@"goodsList"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 38.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *dic = [_dataSource objectAtIndex:section];
    GoodsRecommendSectionHeaderView *view = [GoodsRecommendSectionHeaderView initViewFromNib];
    view.title = [dic objectForKey:@"title"];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsRecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsRecommendCell" forIndexPath:indexPath];
    NSDictionary *dic = [_dataSource objectAtIndex:indexPath.section];
    cell.goodsModel = [[dic objectForKey:@"goodsList"] objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    NSDictionary *dic = [_dataSource objectAtIndex:indexPath.section];
    GoodsDetailModel *goodsModel = [[dic objectForKey:@"goodsList"] objectAtIndex:indexPath.row];
    ctl.goodsId = goodsModel.goodsId;
    ctl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointZero;
    }
    if (scrollView.contentOffset.y > scrollView.bounds.size.height) {
        _scroll2TopBtn.hidden = NO;
    } else {
        _scroll2TopBtn.hidden = YES;
    }
    CGFloat alpha = scrollView.contentOffset.y/150;
    if (alpha > 0.8) {
        alpha = 1;
    }
    if (alpha < 0.2) {
        alpha = 0;
    }
    _navigationBar.alpha = alpha;
}

#pragma mark - GoodsRecommendHeaderViewDelegate

- (void)didSelectItem:(NSString *)itemUri
{
    TZSchemeManager *schemeManager = [[TZSchemeManager alloc] init];
    __weak typeof(GoodsRecommendViewController *)weakSelf = self;
    [schemeManager handleUri:itemUri handleUriCompletionBlock:^(UIViewController *controller, NSString *uri) {
        [weakSelf.navigationController pushViewController:controller animated:YES];
    }];
}

#pragma mark - ErrorEmptyViewDelegate

- (void)reloadPageAction
{
    [self loadData];
}

@end
