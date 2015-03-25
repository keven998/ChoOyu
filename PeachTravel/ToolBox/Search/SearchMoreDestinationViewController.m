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
#import "CityDetailTableViewController.h"
#import "CommonPoiDetailViewController.h"
#import "PoiDetailViewControllerFactory.h"

@interface SearchMoreDestinationViewController () <UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, TaoziMessageSendDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UIButton *positionBtn;
@property (nonatomic, strong) UITableView *tableView;
/**
 *  保存搜索结果
 */
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) CityDestinationPoi *localCity;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL didEndScroll;
@property (nonatomic, assign) BOOL enableLoadMore;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatroView;
@property (nonatomic, strong) TZProgressHUD *hud;


/**
 *  联想的城市数据
 */
@property (nonatomic, strong) NSMutableArray *searchResultArray;

@end

@implementation SearchMoreDestinationViewController

static NSString *reusableCellIdentifier = @"searchResultCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentPage = 0;
    _isLoadingMore = YES;
    _didEndScroll = YES;
    _enableLoadMore = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = @"更多结果";
    
    if (_poiType == kHotelPoi || _poiType == kRestaurantPoi || _poiType == kShoppingPoi) {
        UIView *positionView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, 35)];
        positionView.backgroundColor = [APP_THEME_COLOR colorWithAlphaComponent:0.5];

        _positionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 25)];
        _positionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//        _positionBtn.layer.cornerRadius = 2.0;
//        _positionBtn.clipsToBounds = YES;
        _positionBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
        [_positionBtn setBackgroundImage:[UIImage imageNamed:@"ic_filter_box.png"] forState:UIControlStateNormal];
        [_positionBtn setTitle:@"城市筛选" forState:UIControlStateNormal];
        [_positionBtn setTitleEdgeInsets:UIEdgeInsetsMake(2, 2, 0, 0)];
        [_positionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 2)];
        [_positionBtn setImage:[UIImage imageNamed:@"ic_filter.png"] forState:UIControlStateNormal];
        [_positionBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_positionBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
        _positionBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0];
        [_positionBtn addTarget:self action:@selector(beginSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_positionBtn];
      
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40, 38)];
        _searchBar.delegate = self;
        _searchBar.backgroundColor = [UIColor whiteColor];
        [_searchBar setPlaceholder:@"请输入城市名或拼音"];
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.translucent = YES;
        _searchBar.showsCancelButton = YES;
        _searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
        _searchController.active = NO;
        _searchController.delegate = self;
        _searchController.searchResultsDataSource = self;
        _searchController.searchResultsDelegate = self;
        [_searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"suggestCell"];
        _searchBar.hidden = YES;
        [self.view addSubview:_searchBar];

    }
    [self.view addSubview:self.tableView];
    [self loadDataWithPageIndex:_currentPage];
    
    _hud = [[TZProgressHUD alloc] init];
    __weak typeof(SearchMoreDestinationViewController *)weakSelf = self;
    [_hud showHUDInViewController:weakSelf];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_search_destination_all_result"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_search_destination_all_result"];
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

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 1, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 65)];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_tableView registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:nil]forCellReuseIdentifier:reusableCellIdentifier];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
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

- (NSMutableArray *)searchResultArray
{
    if (!_searchResultArray) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}

- (IBAction)beginSearch:(id)sender
{
    [MobClick event:@"event_filter_city"];
    [_searchBar setFrame:CGRectMake(0, 20, self.view.bounds.size.width-40, 38)];
    [_searchController setActive:YES animated:YES];
    _searchBar.hidden = NO;
    [_searchBar becomeFirstResponder];
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
    NSNumber *imageWidth = [NSNumber numberWithInt:80];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params safeSetObject:_keyWord forKey:@"keyWord"];
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
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

/**
 *  搜索城市的时候联想查询
 */
- (void)loadSuggestionData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:_searchBar.text forKey:@"keyWord"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"page"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"loc"];
    
    [manager GET:API_SUGGESTION parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self analysisSearchData:[responseObject objectForKey:@"result"]];
            
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];

}

- (void)analysisSearchData:(id)json
{
    [self.searchResultArray removeAllObjects];
    for (id dic in [json objectForKey:@"locality"]) {
        CityDestinationPoi *loc = [[CityDestinationPoi alloc] initWithJson:dic];
        [self.searchResultArray addObject:loc];
    }
    [self.searchController.searchResultsTableView reloadData];
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
    if ([tableView isEqual:self.tableView]) {
        if (self.dataSource.count) {
            return 28.0;
        } else return 0;
    } else return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return 54.0;

    } else {
        return 44.0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        return self.dataSource.count;
    }
    return self.searchResultArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        if (self.dataSource.count == 0) {
            return nil;
        }
        NSString *desc;
        switch (_poiType) {
            case kCityPoi:
                desc = @"相关城市";
                
                break;
            case kSpotPoi:
                desc = @"相关景点";
                
                break;
            case kRestaurantPoi:
                desc = @"相关美食";
                
                break;
            case kShoppingPoi:
                desc = @"相关购物";
                
                break;
            case kHotelPoi:
                desc = @"相关酒店";
                break;
                
                
            default:
                break;
        }

        UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 28)];
        headerView.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        headerView.text = [NSString stringWithFormat:@"   %@", desc];
        headerView.backgroundColor = [UIColor whiteColor];
        headerView.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];
        headerView.layer.cornerRadius = 2.0;
        headerView.layer.borderColor = APP_PAGE_COLOR.CGColor;
        headerView.layer.borderWidth = 0.5;
        return headerView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        SuperPoi *poi = [self.dataSource objectAtIndex:indexPath.row];
        SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
        cell.isCanSend = _isCanSend;
        TaoziImage *image = [poi.images firstObject];
        [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
        cell.titleLabel.text = poi.zhName;
        cell.detailLabel.text = poi.address;
        return cell;
        
    } else {
        CityDestinationPoi *poi = [self.searchResultArray objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestCell"];
        cell.textLabel.text = poi.zhName;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
       
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        SuperPoi *poi = [self.dataSource objectAtIndex:indexPath.row];
        
        if (_chatter) {
            TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
            taoziMessageCtl.delegate = self;
            switch (poi.poiType) {
                case kCityPoi:
                    taoziMessageCtl.chatType = TZChatTypeCity;
                    taoziMessageCtl.messageTimeCost = [NSString stringWithFormat:@"%@", ((CityPoi *)poi).timeCostDesc];
                    break;
                    
                case kSpotPoi:
                    taoziMessageCtl.chatType = TZChatTypeSpot;
                    taoziMessageCtl.messageTimeCost = [NSString stringWithFormat:@"%@", ((SpotPoi *)poi).timeCostStr];
                    break;
                    
                case kRestaurantPoi:
                    taoziMessageCtl.chatType = TZChatTypeFood;
                    taoziMessageCtl.messagePrice = ((RestaurantPoi *)poi).priceDesc;
                    break;
                    
                case kShoppingPoi:
                    taoziMessageCtl.chatType = TZChatTypeShopping;
                    break;
                    
                case kHotelPoi:
                    taoziMessageCtl.chatType = TZChatTypeHotel;
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
            taoziMessageCtl.chatter = _chatter;
            taoziMessageCtl.isGroup = _isChatGroup;
            [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:nil];
        } else {
            
            if (poi.poiType == kSpotPoi) {
                SpotDetailViewController *ctl = [[SpotDetailViewController alloc] init];
                ctl.spotId = poi.poiId;
                [self addChildViewController:ctl];
                [self.view addSubview:ctl.view];
                
            } else if (poi.poiType == kCityPoi) {
                CityDetailTableViewController *ctl = [[CityDetailTableViewController alloc] init];
                ctl.cityId = poi.poiId;
                [self.navigationController pushViewController:ctl animated:YES];
                
            } else {
                CommonPoiDetailViewController *ctl = [PoiDetailViewControllerFactory poiDetailViewControllerWithPoiType:poi.poiType];
                ctl.poiId = poi.poiId;
                [self addChildViewController:ctl];
                [self.view addSubview:ctl.view];
            }
        }
        
    } else {
        CityDestinationPoi *cityPoi = [self.searchResultArray objectAtIndex:indexPath.row];
        if ([_localCity.cityId isEqualToString:cityPoi.cityId]) {
            [self.searchDisplayController setActive:NO];

            return;
        } else {
            [self.searchDisplayController setActive:NO];
            _localCity = cityPoi;
            [_positionBtn setTitle:_localCity.zhName forState:UIControlStateNormal];
            [self.dataSource removeAllObjects];
            _currentPage = 0;
            _isLoadingMore = YES;
            _enableLoadMore = NO;
            [self loadDataWithPageIndex:_currentPage];
            _hud = [[TZProgressHUD alloc] init];
            __weak typeof(SearchMoreDestinationViewController *)weakSelf = self;
            [_hud showHUDInViewController:weakSelf];

        }
    }
}

#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self loadSuggestionData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _searchBar.hidden = YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    _searchBar.hidden = YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controlle
    shouldReloadTableForSearchString:(NSString *)searchString {
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (UIView* v in _searchController.searchResultsTableView.subviews) {
            if ([v isKindOfClass: [UILabel class]] &&
                ([[(UILabel*)v text] isEqualToString:@"No Results"] || [[(UILabel*)v text] isEqualToString:@"无结果"]) ) {
                ((UILabel *)v).text = @"";
                break;
            }
        }
    });
    return YES;
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

- (void) beginLoadingMore {
    if (self.tableView.tableFooterView == nil) {
        self.tableView.tableFooterView = self.footerView;
    }
    _isLoadingMore = YES;
    [_indicatroView startAnimating];
    [self loadDataWithPageIndex:(_currentPage + 1)];
}

- (void) loadMoreCompleted {
    if (!_isLoadingMore) return;
    [_indicatroView stopAnimating];
    _isLoadingMore = NO;
}


- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _didEndScroll = YES;
}

- (void) tripUpdate:(id)jsonString {
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



@end
