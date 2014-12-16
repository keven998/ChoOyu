//
//  FavoriteViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavoriteTableViewCell.h"
#import "DKCircleButton.h"
#import "AccountManager.h"
#import "Favorite.h"
#import "SpotDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "CityDetailTableViewController.h"
#import "SRRefreshView.h"
#import "SINavigationMenuView.h"

@interface FavoriteViewController () <SRRefreshDelegate, UITableViewDelegate, UITableViewDataSource, SINavigationMenuDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DKCircleButton *editBtn;
@property (nonatomic) BOOL isEditing;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) FavoriteTableViewCell *prototypeCell;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic) NSUInteger currentPage;

@property (nonatomic, strong) UIActivityIndicatorView *indicatroView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL didEndScroll;
@property (nonatomic, assign) BOOL enableLoadMore;

@property (strong, nonatomic) SRRefreshView *slimeView;

@property (nonatomic, strong) SINavigationMenuView *sortPoiView;

@property (nonatomic, strong) NSArray *urlArray;
/**
 *  当前显示的收藏类型
 */
@property (nonatomic, copy) NSString *currentFavoriteType;

/**
 *  当前页面是否可见，如果可见显示提示，如果不可见不显示提示
 */
@property (nonatomic) BOOL isVisible;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _urlArray = @[@"all", @"city", @"vs", @"restaurant", @"shopping", @"hotel", @"travelNote"];
    _currentFavoriteType = [_urlArray objectAtIndex:0];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToAllPets)];
    [backBtn setImage:[UIImage imageNamed:@"ic_navigation_back.png"]];
    self.navigationItem.leftBarButtonItem = backBtn;
    UIBarButtonItem *barItem= [[UIBarButtonItem alloc] initWithCustomView:self.sortPoiView];
    self.navigationItem.rightBarButtonItem = barItem;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    _isEditing = NO;
    self.navigationItem.title = @"收藏夹";
    
    _selectedIndex = -1;
    _currentPage = 0;
    _isLoadingMore = YES;
    _didEndScroll = YES;
    _enableLoadMore = NO;
    [self pullToRefreash:nil];
    [self.view addSubview:self.editBtn];
    self.slimeView.loading = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreash:) name:updateFavoriteListNoti object:nil];
    _isVisible = YES;
    
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        [_tableView setContentOffset:CGPointMake(0, 10)];
        [_tableView registerNib:[UINib nibWithNibName:@"FavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"favorite_cell"];
    }
    return _tableView;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (SINavigationMenuView *)sortPoiView
{
    if (!_sortPoiView) {
        CGRect frame = CGRectMake(0, 0, 50, 30);
        _sortPoiView = [[SINavigationMenuView alloc] initWithFrame:frame withImage:@"ic_nav_filter_normal.png"];
        [_sortPoiView displayMenuInView:self.navigationController.view];
        _sortPoiView.items = @[@"All", @"城市", @"景点", @"美食", @"购物", @"酒店", @"游记"];
        _sortPoiView.delegate = self;
    }
    return _sortPoiView;
}

- (void)pullToRefreash:(id)sender {
    
    [self loadDataWithPageIndex:0 andFavoriteType:_currentFavoriteType];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isVisible = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)goBackToAllPets
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (DKCircleButton *)editBtn
{
    if (!_editBtn) {
        _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-70.0, 50, 50)];
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit.png"] forState:UIControlStateNormal];
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit_done.png"] forState:UIControlStateSelected];
        [_editBtn addTarget:self action:@selector(editMyGuides:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

/**
 *  点击编辑按钮
 *
 *  @param sender
 */
- (IBAction)editMyGuides:(id)sender
{
    UIButton *btn = sender;
    BOOL isEditing = btn.isSelected;
    _isEditing = !isEditing;
    btn.selected = !isEditing;
    [self.tableView reloadData];
}

/**
 *  点击删除攻略按钮
 *
 *  @param sender
 */
- (IBAction)deleteGuide:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定删除吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
        }
    }];
}


/**
 *  获取我的收藏列表
 */

- (void)loadDataWithPageIndex:(NSInteger)pageIndex andFavoriteType:(NSString *)faType
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params safeSetObject:[NSNumber numberWithInt:pageIndex] forKey:@"page"];
    [params safeSetObject:faType forKey:@"faType"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:API_GET_FAVORITES parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (pageIndex == 0) {
            [self.dataSource removeAllObjects];
        }
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self bindDataToView:responseObject];
            _currentPage = pageIndex;
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        [self loadMoreCompleted];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self loadMoreCompleted];
    }];
    
}

- (void) bindDataToView:(id) responseObject {
    NSArray *datas = [responseObject objectForKey:@"result"];
    if (self.slimeView.loading) {
        [self performSelector:@selector(hideSlimeView) withObject:nil afterDelay:0.7];
    }
    if (datas.count == 0) {
        if (_dataSource.count == 0) {
            if (_isVisible) {
                [self showHint:@"No收藏"];
            }
            [self.tableView reloadData];
        } else {
            [self showHint:@"已取完所有内容啦"];
        }
        return;
    }
   
    for (NSDictionary *favoriteDic in datas) {
        Favorite *favorite = [[Favorite alloc] initWithJson:favoriteDic];
        [self.dataSource addObject:favorite];
    }
    
    [self.tableView reloadData];
    
    if (_dataSource.count >= 15) {
        _enableLoadMore = YES;
    }
   
}

- (void)hideSlimeView
{
    [self.slimeView endRefresh];
}

#pragma mark - SINavigationMenuDelegate

- (void)didSelectItemAtIndex:(NSUInteger)index withSender:(id)sender
{
    _currentFavoriteType = [_urlArray objectAtIndex:index];
    [self pullToRefreash:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"favorite_cell" forIndexPath:indexPath];
    cell.isEditing = _isEditing;
    [cell.deleteBtn addTarget:self action:@selector(deleteGuide:) forControlEvents:UIControlEventTouchUpInside];
    Favorite *item = [_dataSource objectAtIndex:indexPath.row];
    
    if (item.images != nil && item.images.count > 0) {
        [cell.standardImageView sd_setImageWithURL:[NSURL URLWithString:((TaoziImage *)[item.images objectAtIndex:0]).imageUrl]];
    } else {
        cell.standardImageView.image = [UIImage imageNamed:@"country.jpg"];
    }
    cell.contentType.text = [item getTypeDesc];
    cell.contentTitle.text = item.zhName;
    cell.contentLocation.text = item.locality.zhName;
    cell.contentTypeFlag.image = [UIImage imageNamed:[item getTypeFlagName]];
    [cell.contentDescExpandView setTitle:item.desc forState:UIControlStateNormal];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:item.createTime/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.timeLabel.text = [dateFormatter stringFromDate:date];
    
    
    if (indexPath.row != _selectedIndex) {
        cell.contentDescExpandView.selected = NO;
    }
    
    [cell.contentDescExpandView addTarget:self action:@selector(expandDesc:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)expandDesc:(id)sender {
    UIButton *btn = sender;
    CGPoint viewPos = [btn convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:viewPos];
    
//    if (_selectedIndex != -1 && _selectedIndex != indexPath.row) {
//        NSIndexPath *pi = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
//        FavoriteTableViewCell *pc = (FavoriteTableViewCell *)[self.tableView cellForRowAtIndexPath:pi];
//        pc.contentDescExpandView.selected = NO;
//    }
    
    if (!btn.isSelected) {
        _selectedIndex = indexPath.row;
        btn.selected = YES;
    } else {
        _selectedIndex = -1;
        btn.selected = NO;
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedIndex) {
        NSString *text = ((Favorite *)[_dataSource objectAtIndex:indexPath.row]).desc;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.0]};
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
        return 210 + rect.size.height - 34.0 + 20.0;
    }
    return 210.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Favorite *item = [_dataSource objectAtIndex:indexPath.row];
    NSString *type = item.type;
    if ([type isEqualToString:@"vs"]) {
        [self.navigationController pushViewController:[[SpotDetailViewController alloc] init] animated:YES];
    } else if ([type isEqualToString:@"hotel"]) {
//        [self.navigationController pushViewController:[[SpotDetailViewController alloc] init] animated:YES];
#warning no detailpage
    } else if ([type isEqualToString:@"restaurant"]) {
        [self.navigationController pushViewController:[[RestaurantDetailViewController alloc] init] animated:YES];
    } else if ([type isEqualToString:@"shopping"]) {
        [self.navigationController pushViewController:[[ShoppingDetailViewController alloc] init] animated:YES];
    } else if ([type isEqualToString:@"travelNote"]) {
#warning no detailpage
    } else {
        [self.navigationController pushViewController:[[CityDetailTableViewController alloc] init] animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44.0)];
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _footerView.backgroundColor = APP_PAGE_COLOR;
        
        _indicatroView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)];
        [_indicatroView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_footerView addSubview:_indicatroView];
        [_indicatroView setCenter:CGPointMake(CGRectGetWidth(self.tableView.bounds)/2.0, 44.0/2.0)];
    }
    return _footerView;
}

- (void) beginLoadingMore {
    if (self.tableView.tableFooterView == nil) {
        self.tableView.tableFooterView = self.footerView;
    }
    _isLoadingMore = YES;
    [_indicatroView startAnimating];
    [self loadDataWithPageIndex:(_currentPage + 1) andFavoriteType:_currentFavoriteType];
}

- (void) loadMoreCompleted {
    if (!_isLoadingMore) return;
    [_indicatroView stopAnimating];
    _isLoadingMore = NO;
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_isLoadingMore && _didEndScroll && _enableLoadMore) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < 44.0) {
            _didEndScroll = NO;
            [self beginLoadingMore];
        }
    }
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _didEndScroll = YES;
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self pullToRefreash:nil];
    [_slimeView endRefresh];
}


@end
