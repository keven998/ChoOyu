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
#import "TMCache.h"

#define PAGE_COUNT 15

@interface FavoriteViewController () <SRRefreshDelegate, UITableViewDelegate, UITableViewDataSource, SINavigationMenuDelegate, TaoziMessageSendDelegate>

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

- (id)init {
    if (self = [super init]) {
        _urlArray = @[@"all", @"locality", @"vs", @"restaurant", @"shopping", @"hotel", @"travelNote"];
        _currentFavoriteType = [_urlArray objectAtIndex:0];
        _isEditing = NO;
        _selectedIndex = -1;
        _currentPage = 0;
        _isLoadingMore = YES;
        _didEndScroll = YES;
        _enableLoadMore = NO;
        _isVisible = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = @"收藏夹";
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToAllPets)];
    [backBtn setImage:[UIImage imageNamed:@"ic_navigation_back.png"]];
    self.navigationItem.leftBarButtonItem = backBtn;
    UIBarButtonItem *barItem= [[UIBarButtonItem alloc] initWithCustomView:self.sortPoiView];
    self.navigationItem.rightBarButtonItem = barItem;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self.view addSubview:self.editBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreash:) name:updateFavoriteListNoti object:nil];
    
    [self initDataFromCache];
}

- (void) initDataFromCache {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [[TMCache sharedCache] objectForKey:[NSString stringWithFormat:@"%@_favorites", accountManager.account.userId] block:^(TMCache *cache, NSString *key, id object)  {
        if (object != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataSource addObjectsFromArray:object];
                [self.tableView reloadData];
            });
        } else {
            self.slimeView.loading = YES;
            [self pullToRefreash:nil];
        }
    }];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        [_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)];
//        [_tableView setContentOffset:CGPointMake(0, 10)];
        [_tableView registerNib:[UINib nibWithNibName:@"FavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"favorite_cell"];
    }
    return _tableView;
}

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

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = APP_THEME_COLOR;
        _slimeView.slime.skinColor = [UIColor clearColor];
        _slimeView.slime.lineWith = 0.7;
        _slimeView.slime.shadowBlur = 0;
        _slimeView.slime.shadowColor = [UIColor clearColor];
    }
    
    return _slimeView;
}

- (SINavigationMenuView *)sortPoiView
{
    if (!_sortPoiView) {
        CGRect frame = CGRectMake(0, 0, 22.5, 20);
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
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _slimeView.delegate = nil;
    _slimeView = nil;
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
//    btn.selected = !isEditing;
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
            
            
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                [self cacheFirstPage];
//            });
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
    [params safeSetObject:[NSNumber numberWithInt:PAGE_COUNT] forKey:@"pageSize"];
    [params safeSetObject:[NSNumber numberWithInt:pageIndex] forKey:@"page"];
    [params safeSetObject:faType forKey:@"faType"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:API_GET_FAVORITES parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (pageIndex == 0) {
                [self.dataSource removeAllObjects];
            }
            _currentPage = pageIndex;
            [self bindDataToView:responseObject];
            if (pageIndex == 0) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self cacheFirstPage];
                });
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        if (self.slimeView.loading) {
            [self hideSlimeView];
        }
        [self loadMoreCompleted];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self loadMoreCompleted];
        if (self.slimeView.loading) {
            [self hideSlimeView];
        }
    }];
}

- (void) cacheFirstPage {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    int count = _dataSource.count;
    if (count > 0) {
        NSArray *cd = [_dataSource subarrayWithRange:NSMakeRange(0, count > PAGE_COUNT ? PAGE_COUNT : count)];
        [[TMCache sharedCache] setObject:cd forKey:[NSString stringWithFormat:@"%@_favorites", accountManager.account.userId]];
    } else {
        [[TMCache sharedCache] removeObjectForKey:[NSString stringWithFormat:@"%@_favorites", accountManager.account.userId]];
    }
}

- (void) bindDataToView:(id)responseObject {
    NSArray *datas = [responseObject objectForKey:@"result"];
    if (datas.count == 0) {
        if (_currentPage == 0) {
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
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:item.createTime/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.timeLabel.text = [dateFormatter stringFromDate:date];
    
    
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:item.desc];
    [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_SUBTITLE  range:NSMakeRange(0, [desc length])];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, desc.length)];
    [cell.contentDescExpandView setAttributedTitle:desc forState:UIControlStateNormal];
//    if (indexPath.row != _selectedIndex) {
//        cell.contentDescExpandView.selected = NO;
//    } 
    
    [cell.contentDescExpandView addTarget:self action:@selector(expandDesc:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)expandDesc:(id)sender {
    UIButton *btn = sender;
    CGPoint viewPos = [btn convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:viewPos];
    
//    if (!btn.isSelected) {
//        _selectedIndex = indexPath.row;
//        btn.selected = YES;
//    } else {
//        _selectedIndex = -1;
//        btn.selected = NO;
//    }
    
    if (_selectedIndex != indexPath.row) {
        _selectedIndex = indexPath.row;
    } else {
        _selectedIndex = -1;
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - TaoziMessageSendDelegate

- (void)sendCancel
{
    
}

- (void)sendSuccess:(ChatViewController *)chatCtl
{
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedIndex) {
        NSString *text = ((Favorite *)[_dataSource objectAtIndex:indexPath.row]).desc;
        
//        NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:text];
//        [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_SUBTITLE  range:NSMakeRange(0, [desc length])];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
//        [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, desc.length)];
        
//        CGRect rect = [desc boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width - 44.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.0],
                                     NSParagraphStyleAttributeName : style};
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width - 44.0, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
        return 210 + rect.size.height - 24.0;
    }
    return 216;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Favorite *item = [_dataSource objectAtIndex:indexPath.row];
    NSString *type = item.type;
    if (!_selectToSend) {
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
    } else {
        
//TODO:点击发送
        TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
//        taoziMessageCtl.delegate = self;
//        taoziMessageCtl.chatType = TZChatTypeStrategy;
//        taoziMessageCtl.chatter = _chatter;
//        taoziMessageCtl.chatTitle = @"攻略";
//        taoziMessageCtl.messageId = item.itemId;
//        taoziMessageCtl.messageDesc = item.summary;
//        taoziMessageCtl.messageName = guideSummary.title;
//        TaoziImage *image = [guideSummary.images firstObject];
//        taoziMessageCtl.messageImage = image.imageUrl;
//        taoziMessageCtl.messageTimeCost = [NSString stringWithFormat:@"%d天", guideSummary.dayCount];
        
        [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:^(void) {
            
        }];

    }
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
//    if (!_isLoadingMore) return;
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
