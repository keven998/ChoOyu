//
//  SearchDestinationViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SearchDestinationViewController.h"
#import "TripDetail.h"
#import "SearchMoreDestinationViewController.h"
#import "SearchResultTableViewCell.h"
#import "TaoziChatMessageBaseViewController.h"
#import "SpotDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "CityDetailTableViewController.h"
#import "PoiDetailViewControllerFactory.h"
#import "TaoziCollectionLayout.h"
#import "DestinationSearchHistoryCell.h"
#import "SearchDestinationHistoryCollectionReusableView.h"

@interface SearchDestinationViewController () <UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, TaoziMessageSendDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, TaoziLayoutDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UICollectionView *collectionView;

//@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, copy) NSString *keyWord;

@property (nonatomic, strong)NSMutableArray * collectionArray;

@end

@implementation SearchDestinationViewController

static NSString *reusableCellIdentifier = @"searchResultCell";

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"城市/景点/美食/购物"];
    _searchBar.tintColor = COLOR_TEXT_II;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [_searchBar setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [_searchBar setBackgroundColor:APP_THEME_COLOR];
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.navigationItem.titleView = _searchBar;
    
    UIImageView *imageBg = [[UIImageView alloc]initWithFrame:CGRectMake((kWindowWidth - 210)/2, 68, 210, 130)];
    
    imageBg.image = [UIImage imageNamed:@"search_default_background"];
    [self.view addSubview:imageBg];
    
    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
    
    [_searchBar becomeFirstResponder];
    
    
    // 添加UICollectionView
    TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
    layout.delegate = self;
    layout.showDecorationView = NO;
    layout.spacePerItem = 12;
    layout.spacePerLine = 15;
    layout.margin = 10;
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width-29, self.view.bounds.size.height) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = APP_PAGE_COLOR;
    collectionView.showsVerticalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"DestinationSearchHistoryCell" bundle:nil] forCellWithReuseIdentifier:@"searchHistoryCell"];
    [collectionView registerNib:[UINib nibWithNibName:@"SearchDestinationHistoryCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"searchDestinationHeader"];

    [self.view addSubview:collectionView];
    
    // 加载CollectionView的数据
    [self sendRequestGethotSearchResult];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_lxp_search"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_lxp_search"];
    [_searchBar endEditing:YES];
}

// 加载CollectionView的数据源
- (void)setupCollectionDataSourceWithHotSearchResult:(NSArray *)hotSearchResult
{
    NSArray * recentResult = [[TMCache sharedCache] objectForKey:kSearchDestinationCacheKey];
    if (recentResult && hotSearchResult) {
        NSLog(@"%@",recentResult);
        self.collectionArray[0] = recentResult;
        self.collectionArray[1] = hotSearchResult;
        [self.collectionView reloadData];
    }
    NSLog(@"%@",recentResult);
}

#pragma mark - 加载网络数据
- (void)sendRequestGethotSearchResult
{
    // 1.获取请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // 2.发送Get请求
    [manager GET:API_GET_HOT_SEARCH parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray * searchNameArray = [NSMutableArray array];
        NSArray *resultArray = responseObject[@"result"];
        
        for (NSDictionary * resultDict in resultArray) {
            NSString * searchName = resultDict[@"zhName"];
            [searchNameArray addObject:searchName];
        }
        
        [self setupCollectionDataSourceWithHotSearchResult:searchNameArray];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 打印失败信息
        NSLog(@"%@",error);
    }];

}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCollectionView
{
    [_collectionView reloadData];
    _collectionView.hidden = NO;
}

- (void)hideCollectionView
{
    _collectionView.hidden = YES;
}

- (void)clearSearchHistory
{
    [[TMCache sharedCache] removeObjectForKey:kSearchDestinationCacheKey];
    [_collectionArray[0] removeAllObjects];
    [_collectionView reloadData];
}

#pragma mark - getter or setter方法
// 懒加载
- (NSMutableArray *)collectionArray
{
    if (_collectionArray == nil) {
        _collectionArray = [[NSMutableArray alloc] init];
        NSMutableArray *historyArray = [[NSMutableArray alloc] init];
        [_collectionArray addObject:historyArray];
        NSMutableArray *recommendArray = [[NSMutableArray alloc] init];
        [_collectionArray addObject:recommendArray];
    }
    return _collectionArray;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)+60)];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        
        [_tableView registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:nil]forCellReuseIdentifier:reusableCellIdentifier];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 26, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 41)];
        footerView.backgroundColor = APP_PAGE_COLOR;
        _tableView.tableFooterView = footerView;
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self.searchBar endEditing:YES];
    [super touchesEnded:touches withEvent:event];
    if (self.dataSource.count == 0) {
        self.tableView.hidden = YES;
        [self showCollectionView];
    }
}


#pragma mark - private Methods
/**
 *  开始搜索
 */
- (void)loadDataSourceWithKeyWord:(NSString *)keyWord
{
    self.tableView.hidden = NO;
    [self hideCollectionView];
    
    _keyWord = keyWord;
    
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
    [params setObject:keyWord forKey:@"keyword"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"loc"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"vs"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"restaurant"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"hotel"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"shopping"];
    [params setObject:[NSNumber numberWithInt:5] forKey:@"pageSize"];
    
    __weak typeof(SearchDestinationViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    NSLog(@"%@,%@",API_SEARCH,params);
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self analysisData:[responseObject objectForKey:@"result"]];
        } else {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        NSLog(@"%@",error);
    }];
}

- (void)analysisData:(id)json
{
    [self.dataSource removeAllObjects];
    NSMutableDictionary *cityDic = [[NSMutableDictionary alloc] init];
    [cityDic setObject:@"城市" forKey:@"typeDesc"];
    NSMutableArray *cities = [[NSMutableArray alloc] init];
   
    for (id dic in [json objectForKey:@"locality"]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:kCityPoi andJson:dic];
        poi.poiType = kCityPoi;
        [cities addObject:poi];
    }
    if (cities.count > 0) {
        [cityDic setObject:cities forKey:@"content"];
        [self.dataSource addObject:cityDic];
        [cityDic setObject:[NSNumber numberWithInt:kCityPoi] forKey:@"type"];
    }
    NSMutableDictionary *spotDic = [[NSMutableDictionary alloc] init];
    
    [spotDic setObject:@"景点" forKey:@"typeDesc"];
    NSMutableArray *spots = [[NSMutableArray alloc] init];
    for (id dic in [json objectForKey:@"vs"]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:kSpotPoi andJson:dic];
        [spots addObject:poi];
    }
    if (spots.count > 0) {
        [spotDic setObject:spots forKey:@"content"];
        [spotDic setObject:[NSNumber numberWithInt:kSpotPoi] forKey:@"type"];
        
        [self.dataSource addObject:spotDic];
    }
    
    NSMutableDictionary *restaurantDic = [[NSMutableDictionary alloc] init];
    
    [restaurantDic setObject:@"美食" forKey:@"typeDesc"];
    NSMutableArray *restaurants = [[NSMutableArray alloc] init];
    for (id dic in [json objectForKey:@"restaurant"]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:kRestaurantPoi andJson:dic];
        [restaurants addObject:poi];
    }
    if (restaurants.count > 0) {
        [restaurantDic setObject:restaurants forKey:@"content"];
        [restaurantDic setObject:[NSNumber numberWithInt:kRestaurantPoi] forKey:@"type"];
        [self.dataSource addObject:restaurantDic];
    }
    
    NSMutableDictionary *shoppingDic = [[NSMutableDictionary alloc] init];
    
    [shoppingDic setObject:@"购物" forKey:@"typeDesc"];
    NSMutableArray *shoppingArray = [[NSMutableArray alloc] init];
    for (id dic in [json objectForKey:@"shopping"]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:kShoppingPoi andJson:dic];
        [shoppingArray addObject:poi];
    }
    if (shoppingArray.count > 0) {
        [shoppingDic setObject:shoppingArray forKey:@"content"];
        [shoppingDic setObject:[NSNumber numberWithInt:kShoppingPoi] forKey:@"type"];
        
        [self.dataSource addObject:shoppingDic];
    }
    
    NSMutableDictionary *hotelDic = [[NSMutableDictionary alloc] init];
    
    [hotelDic setObject:@"酒店" forKey:@"typeDesc"];
    NSMutableArray *hotels = [[NSMutableArray alloc] init];
    for (id dic in [json objectForKey:@"hotel"]) {
        SuperPoi *poi = [PoiFactory poiWithPoiType:kHotelPoi andJson:dic];
        [hotels addObject:poi];
    }
    if (hotels.count > 0) {
        [hotelDic setObject:hotels forKey:@"content"];
        [hotelDic setObject:[NSNumber numberWithInt:kHotelPoi] forKey:@"type"];
        
        [self.dataSource addObject:hotelDic];
    }
    if (self.dataSource.count>0) {
        [self.tableView reloadData];
    } else {
        NSString *searchStr = [NSString stringWithFormat:@"没有找到“%@”的相关结果", _keyWord];
        [SVProgressHUD showHint:searchStr];
    }
}

- (void)showMore:(UIButton *)sender
{
    [MobClick event:@"button_item_all_search_result"];
    NSDictionary *dic = [self.dataSource objectAtIndex:sender.tag];
    
    SearchMoreDestinationViewController *searchMoreCtl = [[SearchMoreDestinationViewController alloc] init];
    searchMoreCtl.isCanSend = _isCanSend;
    searchMoreCtl.poiType = [[dic objectForKey:@"type"] integerValue];
    NSString *poiTypeDesc;
    switch ([[dic objectForKey:@"type"] integerValue]) {
        case kCityPoi:
            poiTypeDesc = @"locality";
            searchMoreCtl.titleStr = @"全部城市";
            break;
        case kSpotPoi:
            poiTypeDesc = @"vs";
            searchMoreCtl.titleStr = @"全部景点";
            break;
        case kRestaurantPoi:
            poiTypeDesc = @"restaurant";
            searchMoreCtl.titleStr = @"全部美食";
            break;
        case kShoppingPoi:
            poiTypeDesc = @"shopping";
            searchMoreCtl.titleStr = @"全部购物";
            break;
        case kHotelPoi:
            poiTypeDesc = @"hotel";
            searchMoreCtl.titleStr = @"全部酒店";
            break;
            
        default:
            break;
    }
    searchMoreCtl.poiTypeDesc = poiTypeDesc;
    searchMoreCtl.keyWord = _keyWord;
    searchMoreCtl.chatterId = _chatterId;
    searchMoreCtl.chatType = _chatType;
    [self.navigationController pushViewController:searchMoreCtl animated:YES];
}

- (IBAction)sendPoi:(UIButton *)sender
{
    [MobClick event:@"button_item_lxp_send_search_result"];
    
    CGPoint point = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    SuperPoi *poi = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    
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
    [self.navigationController presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:nil];
}

#pragma mark - tableview datasource & delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *content = [[self.dataSource objectAtIndex:section] objectForKey:@"content"];
    return content.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWindowWidth, 35)];
    headerView.backgroundColor = APP_PAGE_COLOR;
    NSString *typeDesc = [[self.dataSource objectAtIndex:section] objectForKey:@"typeDesc"];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 50, 25)];
    headerLabel.textColor = COLOR_TEXT_I;
    headerLabel.text = [NSString stringWithFormat:@"   %@", typeDesc];
    headerLabel.font = [UIFont systemFontOfSize:14.0];
    
    NSArray *content = [[self.dataSource objectAtIndex:section] objectForKey:@"content"];
    if (content.count >= 5) {
        UIButton *showMoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 100, 0, 100, CGRectGetHeight(headerView.frame))];
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"查看全部 " attributes:@{NSForegroundColorAttributeName : COLOR_TEXT_II, NSFontAttributeName: [UIFont systemFontOfSize:12]}];
        NSMutableAttributedString *showMoreStr = [[NSMutableAttributedString alloc]initWithAttributedString:str];
        
        showMoreBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        showMoreBtn.tag = section;
        [showMoreBtn addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
        showMoreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        NSAttributedString *more1 = [[NSAttributedString alloc] initWithString:typeDesc attributes:@{NSForegroundColorAttributeName : APP_THEME_COLOR, NSFontAttributeName: [UIFont systemFontOfSize:12]}];
        [showMoreStr appendAttributedString:more1];
        NSAttributedString *sstr = [[NSAttributedString alloc]initWithString:@" >"];
        [showMoreStr appendAttributedString:sstr];
        [showMoreBtn setAttributedTitle:showMoreStr forState:UIControlStateNormal];
        showMoreBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
        [headerView addSubview:showMoreBtn];
    }
    
    [headerView addSubview:headerLabel];
    return headerView;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *poi = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
    
    if (poi.poiType == kRestaurantPoi || poi.poiType == kShoppingPoi || poi.poiType == kHotelPoi || poi.poiType == kSpotPoi) {
        if ([poi.address isBlankString]||poi.address.length == 0) {
            poi.address = poi.zhName;
        }
        TaoziImage *image = [poi.images firstObject];
        [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
        cell.titleLabel.text = poi.zhName;
        cell.detailLabel.text = poi.address;
    } else {
        TaoziImage *image = [poi.images firstObject];
        [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
        cell.titleLabel.text = poi.zhName;
        cell.detailLabel.text = @"";
    }
    cell.isCanSend = _isCanSend;
    
    if (_isCanSend) {
        [cell.sendBtn addTarget:self action:@selector(sendPoi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    SuperPoi *poi = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    if (poi.poiType == kSpotPoi) {
        SpotDetailViewController *ctl = [[SpotDetailViewController alloc] init];
        ctl.spotId = poi.poiId;
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (poi.poiType == kCityPoi) {
        CityDetailTableViewController *ctl = [[CityDetailTableViewController alloc] init];
        ctl.cityId = poi.poiId;
        [self.navigationController pushViewController:ctl animated:YES];
    } else {
        CommonPoiDetailViewController *ctl = [PoiDetailViewControllerFactory poiDetailViewControllerWithPoiType:poi.poiType];
        ctl.poiId = poi.poiId;
        [self.navigationController pushViewController:ctl animated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar endEditing:YES];
}


#pragma mark - 实现UICollectionView的数据源以及代理方法

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _collectionArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[_collectionArray objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DestinationSearchHistoryCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchHistoryCell" forIndexPath:indexPath];
    NSArray *array = [_collectionArray objectAtIndex:indexPath.section];
    cell.titleLabel.text = array[indexPath.row];
    return cell;
}

// collection的头部
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SearchDestinationHistoryCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"searchDestinationHeader" forIndexPath:indexPath];
        if (indexPath.section == 0 && [[self.collectionArray objectAtIndex:0] count]) {
            headerView.titleLabel.text = @"历史搜索";
            headerView.actionButton.hidden = NO;
            [headerView.actionButton setTitle:@"清除" forState:UIControlStateNormal];
            [headerView.actionButton addTarget:self action:@selector(clearSearchHistory) forControlEvents:UIControlEventTouchUpInside];
            
        } else if (indexPath.section == 1 && [[self.collectionArray objectAtIndex:1] count]) {
            headerView.titleLabel.text = @"热门搜索";
            headerView.actionButton.hidden = YES;
        }
        return headerView;
    }
    
    return nil;
}


// 选中某一个item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar endEditing:YES];
    NSArray *array = [self.collectionArray objectAtIndex:indexPath.section];
    [self loadDataSourceWithKeyWord:array[indexPath.row]];
}

#pragma mark - TaoziLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [_collectionArray objectAtIndex:indexPath.section];
    NSString *title = [array objectAtIndex:indexPath.row];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]}];
    return CGSizeMake(size.width+20, 30);
}

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && [[self.collectionArray objectAtIndex:0] count]) {
        return CGSizeMake(kWindowWidth, 50);
    } else if (indexPath.section == 1 && [[self.collectionArray objectAtIndex:1] count]) {
        return CGSizeMake(kWindowWidth, 50);
    }
    return CGSizeZero;
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return _collectionArray.count;
}

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[_collectionArray objectAtIndex:section] count];
}

- (CGFloat)tzcollectionLayoutWidth
{
    return self.view.bounds.size.width-20;
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar endEditing:YES];
    
    // 将搜索结果存入到数据库中
    NSArray * recentSearch = [[TMCache sharedCache] objectForKey:kSearchDestinationCacheKey];
    NSMutableArray * mutableArray;
    if (recentSearch) {
        mutableArray = [recentSearch mutableCopy];
    } else {
        mutableArray = [[NSMutableArray alloc] init];
    }
    for (NSString *str in mutableArray) {
        if ([str isEqualToString:searchBar.text]) {
            [mutableArray removeObject:str];
            break;
        }
    }
    if (mutableArray.count >= 10) {
        [mutableArray removeLastObject];
    }
    [mutableArray insertObject:searchBar.text atIndex:0];
    [[TMCache sharedCache] setObject:mutableArray forKey:kSearchDestinationCacheKey];
    self.collectionArray[0] = mutableArray;
    [self loadDataSourceWithKeyWord:searchBar.text];
   
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self.dataSource removeAllObjects];
        [_tableView reloadData];
        _tableView.hidden = YES;
        [self showCollectionView];
    }
}

#pragma mark - TaoziMessageSendDelegate

//用户确定发送景点给朋友
- (void)sendSuccess:(ChatViewController *)chatCtl
{
    [self dismissPopup];
    [SVProgressHUD showSuccessWithStatus:@"已发送~"];
    [self performSelector:@selector(dismissAfterSended) withObject:nil afterDelay:0.5];
}

- (void)sendCancel
{
    [self dismissPopup];
    [self performSelector:@selector(dismissAfterSended) withObject:nil afterDelay:0.5];
}

/**
 *  消除发送 poi 对话框
 *  @param sender
 */
- (void)dismissPopup
{
    if (self.navigationController.popupViewController != nil) {
        [self.navigationController dismissPopupViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - private method

- (void)dismissAfterSended
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end






