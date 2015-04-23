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

@interface SearchDestinationViewController () <UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, TaoziMessageSendDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

//@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, copy) NSString *keyWord;


@end

@implementation SearchDestinationViewController

static NSString *reusableCellIdentifier = @"searchResultCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    _searchBar.searchBarStyle = UISearchBarStyleProminent;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"城市、景点、美食、游记"];
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
//    _searchBar.showsCancelButton = YES;
    [_searchBar setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor redColor]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.navigationItem.titleView = _searchBar;
    
//    [self.view addSubview:_searchBar];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.view.bounds), 50)];
    label.font = [UIFont systemFontOfSize:13.0];
    label.textColor = TEXT_COLOR_TITLE_PH;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.text = @"旅行搜搜\n搜索旅行中的城市、景点、美食、游记";
    [self.view addSubview:label];
    
    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
    
    [_searchBar becomeFirstResponder];
}

- (void) goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_search_destination"];
    [self.navigationController.navigationBar setBackgroundImage:[ConvertMethods createImageWithColor:APP_BORDER_COLOR] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_search_destination"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

    [_searchBar endEditing:YES];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)+60)];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.backgroundColor = APP_PAGE_COLOR;

        [_tableView registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:nil]forCellReuseIdentifier:reusableCellIdentifier];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
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

- (void)tapTouch
{
    [self.searchBar endEditing:YES];
//    [self.tableView removeGestureRecognizer:_tap];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self.searchBar endEditing:YES];
    [super touchesEnded:touches withEvent:event];
    [self goBack];
}

/**
 *  开始搜索
 */
- (void)loadDataSourceWithKeyWord:(NSString *)keyWord
{
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
    [params setObject:keyWord forKey:@"keyWord"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"loc"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"vs"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"restaurant"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"hotel"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"shopping"];
    [params setObject:[NSNumber numberWithInt:5] forKey:@"pageCnt"];

     __weak typeof(SearchDestinationViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self analysisData:[responseObject objectForKey:@"result"]];
        } else {
//             if (self.isShowing) {
//                [SVProgressHUD showHint:@"请求也是失败了"];
//            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
//        if (self.isShowing) {
//            [SVProgressHUD showHint:@"呃～好像没找到网络"];
//        }
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
        self.tableView.hidden = NO;
        [self.tableView reloadData];

    } else {
        self.tableView.hidden = YES;
    }
}

- (void)showMore:(UIButton *)sender
{
    [MobClick event:@"event_click_more_search_result"];
    
    NSDictionary *dic = [self.dataSource objectAtIndex:sender.tag];
    
    SearchMoreDestinationViewController *searchMoreCtl = [[SearchMoreDestinationViewController alloc] init];
    searchMoreCtl.isCanSend = _isCanSend;
    searchMoreCtl.poiType = [[dic objectForKey:@"type"] integerValue];
    NSString *poiTypeDesc;
    switch ([[dic objectForKey:@"type"] integerValue]) {
        case kCityPoi:
            poiTypeDesc = @"locality";
            
            break;
        case kSpotPoi:
            poiTypeDesc = @"vs";
            
            break;
        case kRestaurantPoi:
            poiTypeDesc = @"restaurant";
            
            break;
        case kShoppingPoi:
            poiTypeDesc = @"shopping";
            
            break;
        case kHotelPoi:
            poiTypeDesc = @"hotel";
            break;
            
            
        default:
            break;
    }
    searchMoreCtl.poiTypeDesc = poiTypeDesc;
    searchMoreCtl.keyWord = _keyWord;
    searchMoreCtl.chatter = _chatter;
    searchMoreCtl.isChatGroup = _isChatGroup;
    [self.navigationController pushViewController:searchMoreCtl animated:YES];
}

- (IBAction)sendPoi:(UIButton *)sender
{
    CGPoint point = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    SuperPoi *poi = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    
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
    return 54.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSArray *content = [[self.dataSource objectAtIndex:section] objectForKey:@"content"];
    if (content.count < 5) {
        return 10;
    } else {
        return 50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView;
    NSArray *content = [[self.dataSource objectAtIndex:section] objectForKey:@"content"];
    if (content.count < 5) {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 10)];
        footerView.backgroundColor = APP_PAGE_COLOR;
    } else {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
        footerView.backgroundColor = APP_PAGE_COLOR;
        UIButton *showMoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40)];
        [showMoreBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [showMoreBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_BORDER_COLOR] forState:UIControlStateHighlighted];
        [showMoreBtn setTitleColor:APP_SUB_THEME_COLOR forState:UIControlStateNormal];
        [showMoreBtn setTitleColor:APP_SUB_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
        [showMoreBtn setTitle:@"查看全部结果" forState:UIControlStateNormal];
        showMoreBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        showMoreBtn.tag = section;
        [showMoreBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 11, 0, 0)];
        [showMoreBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        showMoreBtn.layer.borderColor = APP_PAGE_COLOR.CGColor;
        showMoreBtn.layer.borderWidth = 0.5;
        [showMoreBtn addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
        [showMoreBtn setImage:[UIImage imageNamed:@"ic_search.png"] forState:UIControlStateNormal];
        showMoreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [footerView addSubview:showMoreBtn];
    }
    return footerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *typeDesc = [[self.dataSource objectAtIndex:section] objectForKey:@"typeDesc"];
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 28)];
    headerView.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    headerView.text = [NSString stringWithFormat:@"   %@", typeDesc];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.font = [UIFont systemFontOfSize:12.0];
    headerView.layer.cornerRadius = 2.0;
    headerView.layer.borderColor = APP_PAGE_COLOR.CGColor;
    headerView.layer.borderWidth = 0.5;
    return headerView;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *poi = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];

    if (poi.poiType == kRestaurantPoi || poi.poiType == kShoppingPoi || poi.poiType == kHotelPoi || poi.poiType == kSpotPoi) {
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
    [MobClick event:@"event_click_search_result_item"];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    SuperPoi *poi = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];

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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar endEditing:YES];
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"开始搜索");
    [_searchBar endEditing:YES];
    [self loadDataSourceWithKeyWord:searchBar.text];
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






