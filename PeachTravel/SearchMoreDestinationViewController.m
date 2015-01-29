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
#import "PoiSummary.h"
#import "SpotDetailViewController.h"
#import "CityDetailTableViewController.h"
#import "CommonPoiDetailViewController.h"

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
    self.navigationItem.title = _titleStr;
    if (_poiType == kHotelPoi || _poiType == kRestaurantPoi || _poiType == kShoppingPoi) {
        UIView *positionView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, 35)];
        positionView.backgroundColor = [APP_THEME_COLOR colorWithAlphaComponent:0.5];

        _positionBtn = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-150-30, 0, 150, 35)];
        _positionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_positionBtn setTitle:@"未选择" forState:UIControlStateNormal];
        [_positionBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        _positionBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0];
        [_positionBtn addTarget:self action:@selector(beginSearch:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *extender = [[UIImageView alloc] initWithFrame:CGRectMake(kWindowWidth-20, 12.5, 6, 10)];
        [extender setImage:[UIImage imageNamed:@"cell_accessory_pink.png"]];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 0, 100, 35)];
        titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = @"所在城市";
        titleLabel.userInteractionEnabled = NO;
        [positionView addSubview:extender];
        [positionView addSubview:_positionBtn];
        [positionView addSubview:titleLabel];
        [self.view addSubview:positionView];
        
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40, 38)];
//        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
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
        
        [self.view addSubview:_searchBar];

    }
    [self.view addSubview:self.tableView];
    [self loadDataWithPageIndex:_currentPage];
    
    _hud = [[TZProgressHUD alloc] init];
    __weak typeof(SearchMoreDestinationViewController *)weakSelf = self;
    [_hud showHUDInViewController:weakSelf];
   
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
        if (_poiType == kHotelPoi || _poiType == kRestaurantPoi || _poiType == kShoppingPoi) {

            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 64+50, kWindowWidth-22, kWindowHeight - 114)];
        } else {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 64+10, kWindowWidth-22, kWindowHeight - 74)];

        }
        _tableView.backgroundColor = APP_PAGE_COLOR;
        
        [_tableView registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:nil]forCellReuseIdentifier:reusableCellIdentifier];
        
        _tableView.layer.cornerRadius = 2.0;
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
    [_searchBar setFrame:CGRectMake(0, 20, self.view.bounds.size.width-40, 38)];
    [_searchController setActive:YES animated:YES];
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
    [params safeSetObject:_localCity.cityId forKey:@"locId"];
   
    
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self loadMoreCompleted];
        NSLog(@"%@", responseObject);
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
    [self.dataSource removeAllObjects];
    for (id dic in [json objectForKey:_poiTypeDesc]) {
        PoiSummary *poi = [[PoiSummary alloc] initWithJson:dic];
        [self.dataSource addObject:poi];
    }
    [self.tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSString *typeDesc = [[self.dataSource objectAtIndex:section] objectForKey:@"typeDesc"];
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, kWindowWidth-22, 28)];
    headerView.textColor = UIColorFromRGB(0x797979);
    headerView.text = [NSString stringWithFormat:@"   %@",typeDesc];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];
    headerView.layer.cornerRadius = 2.0;
    headerView.layer.borderColor = APP_PAGE_COLOR.CGColor;
    headerView.layer.borderWidth = 0.8;
    return headerView;
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

        UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, kWindowWidth-22, 28)];
        headerView.textColor = UIColorFromRGB(0x797979);
        headerView.text = [NSString stringWithFormat:@"   %@",desc];
        headerView.backgroundColor = [UIColor whiteColor];
        headerView.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];
        headerView.layer.cornerRadius = 2.0;
        headerView.layer.borderColor = APP_PAGE_COLOR.CGColor;
        headerView.layer.borderWidth = 0.8;
        return headerView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        PoiSummary *poi = [self.dataSource objectAtIndex:indexPath.row];
        SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
        
        if (poi.poiType == kRestaurantPoi || poi.poiType == kShoppingPoi || poi.poiType == kHotelPoi) {
            TaoziImage *image = [poi.images firstObject];
            [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
            cell.titleLabel.text = poi.zhName;
            cell.detailLabel.text = poi.address;
            
        } else {
            TaoziImage *image = [poi.images firstObject];
            [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
            cell.titleLabel.text = poi.zhName;
        }
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
        PoiSummary *poi = [self.dataSource objectAtIndex:indexPath.row];
        
        if (_chatter) {
            TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
            taoziMessageCtl.delegate = self;
            switch (_poiType) {
                case kCityPoi:
                    taoziMessageCtl.chatType = TZChatTypeCity;
                    
                    break;
                case kSpotPoi:
                    taoziMessageCtl.chatType = TZChatTypeSpot;
                    
                    break;
                    
                case kRestaurantPoi:
                    taoziMessageCtl.chatType = TZChatTypeFood;
                    
                    break;
                    
                case kShoppingPoi:
                    taoziMessageCtl.chatType = TZChatTypeShopping;
                    
                    break;
                    
                case kHotelPoi:
                    taoziMessageCtl.chatType = TZChatTypeHotel;
                    
                    break;
                default:
                    break;
            }
            taoziMessageCtl.messageId = poi.poiId;
            taoziMessageCtl.messageDesc = poi.desc;
            taoziMessageCtl.messageName = poi.zhName;
            TaoziImage *image = [poi.images firstObject];
            taoziMessageCtl.messageImage = image.imageUrl;
            taoziMessageCtl.messageTimeCost = [NSString stringWithFormat:@"%@", poi.timeCost];
            taoziMessageCtl.messageAddress = poi.address;
            taoziMessageCtl.messagePrice = poi.priceDesc;
            taoziMessageCtl.messageRating = poi.rating;
            taoziMessageCtl.chatter = _chatter;
            taoziMessageCtl.isGroup = _isChatGroup;
            [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:^(void) {
                
            }];
        } else {
            if (poi.poiType == kSpotPoi) {
                SpotDetailViewController *ctl = [[SpotDetailViewController alloc] init];
                ctl.spotId = poi.poiId;
                [self addChildViewController:ctl];
                [self.view addSubview:ctl.view];
                
            } else if (poi.poiType == kHotelPoi) {
                CommonPoiDetailViewController *ctl = [[CommonPoiDetailViewController alloc] init];
                ctl.poiId = poi.poiId;
                ctl.poiType = kHotelPoi;
                [self addChildViewController:ctl];
                [self.view addSubview:ctl.view];
                
            } else if (poi.poiType == kRestaurantPoi) {
                CommonPoiDetailViewController *ctl = [[CommonPoiDetailViewController alloc] init];
                ctl.poiType = kRestaurantPoi;
                ctl.poiId = poi.poiId;
                [self addChildViewController:ctl];
                [self.view addSubview:ctl.view];
                
            } else if (poi.poiType == kShoppingPoi) {
                CommonPoiDetailViewController *ctl = [[CommonPoiDetailViewController alloc] init];
                ctl.poiId = poi.poiId;
                ctl.poiType = kShoppingPoi;
                [self addChildViewController:ctl];
                [self.view addSubview:ctl.view];
                
            } else if (poi.poiType == kCityPoi) {
                CityDetailTableViewController *ctl = [[CityDetailTableViewController alloc] init];
                ctl.cityId = poi.poiId;
                [self.navigationController pushViewController:ctl animated:YES];
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
            [self loadDataWithPageIndex:_currentPage];
            _hud = [[TZProgressHUD alloc] init];
            __weak typeof(SearchMoreDestinationViewController *)weakSelf = self;
            [_hud showHUDInViewController:weakSelf];

        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self loadSuggestionData];
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
    
    NSLog(@"我要加载到第%lu",(long)_currentPage+1);
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
    
    [SVProgressHUD showSuccessWithStatus:@"已发送~"];
    
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
        [self dismissPopupViewControllerAnimated:YES completion:^{
        }];
    }
}



@end
