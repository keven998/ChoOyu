//
//  SearchMoreDestinationViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SearchMoreDestinationViewController.h"
#import "SearchResultTableViewCell.h"
#import "CityDestinationPoi.h"
#import "TaoziChatMessageBaseViewController.h"
#import "SpotDetailViewController.h"
#import "CityDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "PoiDetailViewControllerFactory.h"
#import "SuggestionDestinationTableViewController.h"

@interface SearchMoreDestinationViewController () <UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, TaoziMessageSendDelegate, UISearchDisplayDelegate, SuggestionDestinationTableViewControllerDelegate>

@property (nonatomic, strong) UIButton *positionBtn;
@property (nonatomic, strong) UITableView *tableView;
/**
 *  保存搜索结果
 */
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) CityDestinationPoi *localCity;

@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL didEndScroll;
@property (nonatomic, assign) BOOL enableLoadMore;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatroView;
@property (nonatomic, strong) TZProgressHUD *hud;

@end

@implementation SearchMoreDestinationViewController

static NSString *reusableCellIdentifier = @"searchResultCell";

- (id)init
{
    if (self = [super init]) {
        _currentPage = 0;
        _isLoadingMore = YES;
        _didEndScroll = YES;
        _enableLoadMore = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = _titleStr;
    
    if (_poiType == kHotelPoi || _poiType == kRestaurantPoi || _poiType == kShoppingPoi || _poiType == kSpotPoi) {
        _positionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        _positionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_positionBtn setImage:[UIImage imageNamed:@"icon_navigation_map.png"] forState:UIControlStateNormal];
        _positionBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [_positionBtn addTarget:self action:@selector(beginSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_positionBtn];
    }
    [self.view addSubview:self.tableView];
    [self loadDataWithPageIndex:_currentPage];
    
    _hud = [[TZProgressHUD alloc] init];
    __weak typeof(SearchMoreDestinationViewController *)weakSelf = self;
    [_hud showHUDInViewController:weakSelf content:64];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
}

- (IBAction)sendPoi:(UIButton *)sender
{
    [MobClick event:@"button_item_lxp_send_search_result"];
    
    CGPoint point = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    SuperPoi *poi = [self.dataSource objectAtIndex:indexPath.row];
    
    TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
    taoziMessageCtl.delegate = self;
    switch (poi.poiType) {
        case kCityPoi:
            taoziMessageCtl.messageType = IMMessageTypeCityPoiMessageType;
            taoziMessageCtl.messageTimeCost = [NSString stringWithFormat:@"%@", ((CityPoi *)poi).timeCostDesc];
            break;
            
        case kSpotPoi:
            taoziMessageCtl.messageType = IMMessageTypeSpotMessageType;
            taoziMessageCtl.messageTimeCost = [NSString stringWithFormat:@"%@", ((SpotPoi *)poi).timeCostStr];
            break;
            
        case kRestaurantPoi:
            taoziMessageCtl.messageType = IMMessageTypeRestaurantMessageType;
            taoziMessageCtl.messagePrice = ((RestaurantPoi *)poi).priceDesc;
            break;
            
        case kShoppingPoi:
            taoziMessageCtl.messageType = IMMessageTypeShoppingMessageType;
            break;
            
        case kHotelPoi:
            taoziMessageCtl.messageType = IMMessageTypeHotelMessageType;
            taoziMessageCtl.messagePrice = ((HotelPoi *)poi).priceDesc;
            break;
            
        default:
            break;
    }
    taoziMessageCtl.messageId = poi.poiId;
    taoziMessageCtl.messageDesc = poi.desc;
    taoziMessageCtl.messageName = poi.zhName;
    TaoziImage *image = [poi.images firstObject];
    taoziMessageCtl.messageImage = image.imageUrl;
    taoziMessageCtl.messageAddress = poi.address;
    taoziMessageCtl.messageRating = poi.rating;
    taoziMessageCtl.chatterId = _chatterId;
    taoziMessageCtl.chatType = _chatType;
    [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:nil];
}


- (UIView *)footerView
{
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

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_tableView registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:nil]forCellReuseIdentifier:reusableCellIdentifier];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 35)];
        _tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    }
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (IBAction)beginSearch:(id)sender
{
    SuggestionDestinationTableViewController *ctl = [[SuggestionDestinationTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    ctl.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:ctl];
    [self presentViewController:navi animated:YES completion:nil];
}

/**
 *  开始从网络上加载数据
 */
- (void)loadDataWithPageIndex:(NSInteger)pageIndex
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:270];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params safeSetObject:_keyWord forKey:@"keyword"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:_poiTypeDesc];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [params safeSetObject:_localCity.cityId forKey:@"locId"];
    
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self loadMoreCompleted];
        _currentPage = pageIndex;
        if (_hud) {
            [_hud hideTZHUD];
            _hud = nil;
        }
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self analysisData:[responseObject objectForKey:@"result"]];
            
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self loadMoreCompleted];
        if (_hud) {
            [_hud hideTZHUD];
            _hud = nil;
        }
        if (self.isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
    }];
}

- (void)analysisData:(id)json
{
    if ([[json objectForKey:_poiTypeDesc] count] < 15) {
        _enableLoadMore = NO;
    }
    for (id dic in [json objectForKey:_poiTypeDesc]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:_poiType andJson:dic];
        [self.dataSource addObject:poi];
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.dataSource.count) {
        return 35;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 119;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.dataSource.count == 0) {
        return nil;
    }
    NSString *desc;
    switch (_poiType) {
        case kCityPoi:
            desc = @"城市";
            
            break;
        case kSpotPoi:
            desc = @"景点";
            
            break;
        case kRestaurantPoi:
            desc = @"美食";
            
            break;
        case kShoppingPoi:
            desc = @"购物";
            
            break;
        case kHotelPoi:
            desc = @"酒店";
            break;
            
            
        default:
            break;
    }
    
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.view.bounds), 25)];
    headerView.textColor = COLOR_TEXT_I;
    headerView.text = [NSString stringWithFormat:@"   %@", desc];
    headerView.font = [UIFont systemFontOfSize:14.0];
    
    return headerView;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *poi = [self.dataSource objectAtIndex:indexPath.row];
    SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
    cell.isCanSend = _isCanSend;
    TaoziImage *image = [poi.images firstObject];
    [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    cell.titleLabel.text = poi.zhName;
    cell.detailLabel.text = poi.address;
    cell.ratingView.rating = poi.rating;
    cell.tagsArray = poi.style;
    if (_isCanSend) {
        [cell.sendBtn addTarget:self action:@selector(sendPoi:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    SuperPoi *poi = [self.dataSource objectAtIndex:indexPath.row];
    if (poi.poiType == kSpotPoi) {
        SpotDetailViewController *ctl = [[SpotDetailViewController alloc] init];
        ctl.spotId = poi.poiId;
        [self.navigationController pushViewController:ctl animated:YES];
        
    } else if (poi.poiType == kCityPoi) {
        CityDetailViewController *ctl = [[CityDetailViewController alloc] init];
        ctl.cityId = poi.poiId;
        [self.navigationController pushViewController:ctl animated:YES];
        
    } else {
        CommonPoiDetailViewController *ctl = [PoiDetailViewControllerFactory poiDetailViewControllerWithPoiType:poi.poiType];
        ctl.poiId = poi.poiId;
        [self.navigationController pushViewController:ctl animated:YES];
    }
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
}

- (void) beginLoadingMore
{
    if (self.tableView.tableFooterView == nil) {
        self.tableView.tableFooterView = self.footerView;
    }
    _isLoadingMore = YES;
    [_indicatroView startAnimating];
    [self loadDataWithPageIndex:(_currentPage + 1)];
}

- (void) loadMoreCompleted
{
    if (!_isLoadingMore) return;
    [_indicatroView stopAnimating];
    _isLoadingMore = NO;
    _didEndScroll = YES;
}


- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _didEndScroll = YES;
}

- (void) tripUpdate:(id)jsonString
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[TMCache sharedCache] setObject:jsonString forKey:@"last_tripdetail"];
    });
}

#pragma mark - TaoziMessageSendDelegate

//用户确定发送景点给朋友
- (void)sendSuccess:(ChatViewController *)chatCtl
{
    [self dismissPopup];
    
    [SVProgressHUD showHint:@"已发送~"];
    [self performSelector:@selector(dismissAfterSended) withObject:nil afterDelay:0.5];    
}

- (void)sendCancel
{
    [self dismissPopup];
}

/**
 *  消除发送 poi 对话框
 *  @param sender
 */
- (void)dismissPopup
{
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - private method

- (void)dismissAfterSended
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - SuggestionDestinationTableViewControllerDelegate
- (void)didSelectDestination:(CityDestinationPoi *)cityPoi
{
    if ([_localCity.cityId isEqualToString:cityPoi.cityId]) {
        return;
        
    } else {
        _localCity = cityPoi;
        [self.dataSource removeAllObjects];
        _currentPage = 0;
        _isLoadingMore = YES;
        _enableLoadMore = NO;
        [self loadDataWithPageIndex:_currentPage];
        _hud = [[TZProgressHUD alloc] init];
        __weak typeof(SearchMoreDestinationViewController *)weakSelf = self;
        [_hud showHUDInViewController:weakSelf content:64];
        
    }
}


@end
