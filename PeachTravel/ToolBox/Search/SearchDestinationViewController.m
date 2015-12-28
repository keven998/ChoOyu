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
#import "CityDetailViewController.h"
#import "PoiDetailViewControllerFactory.h"
#import "TaoziCollectionLayout.h"
#import "DestinationSearchHistoryCell.h"
#import "SearchDestinationHistoryCollectionReusableView.h"
#import "SearchDestinationRecommendViewController.h"
#import "PoiManager.h"
#import "SuperWebViewController.h"

@interface SearchDestinationViewController () <UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, TaoziMessageSendDelegate, SearchDestinationRecommendDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) SearchDestinationRecommendViewController *searchRecommendViewController;
@property (nonatomic, copy) NSString *keyWord;

//如果搜美食的时候搜到“北京”，那么在 tableview 的头部放上北京美食简介
@property (nonatomic, strong) NSDictionary *descriptionOfSerachText;

@end

@implementation SearchDestinationViewController

static NSString *reusableCellIdentifier = @"searchResultCell";

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;

    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    NSString *placeholderText;
    if (_searchPoiType == kSpotPoi) {
        placeholderText = @"搜索景点";
    } else if (_searchPoiType == kRestaurantPoi) {
        placeholderText = @"搜索美食";
    } else if (_searchPoiType == kShoppingPoi) {
        placeholderText = @"搜索购物";
    } else if (_searchPoiType == kCityPoi) {
        placeholderText = @"搜索城市";

    } else {
        placeholderText = @"城市/景点/美食/购物";
    }
    [_searchBar setPlaceholder:placeholderText];
    _searchBar.tintColor = [UIColor whiteColor];
    _searchBar.showsCancelButton = YES;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"icon_search_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [_searchBar setTranslucent:YES];
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.navigationItem.titleView = _searchBar;
    
    UIImageView *imageBg = [[UIImageView alloc]initWithFrame:CGRectMake((kWindowWidth - 210)/2, 68, 210, 130)];
    
    imageBg.image = [UIImage imageNamed:@"search_default_background"];

    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
    
    [self addChildViewController:self.searchRecommendViewController];
    [self.view addSubview:self.searchRecommendViewController.view];
    self.searchRecommendViewController.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64);
    [self.searchRecommendViewController willMoveToParentViewController:self];
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

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter or setter方法
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        
        [_tableView registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:nil]forCellReuseIdentifier:reusableCellIdentifier];
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

- (SearchDestinationRecommendViewController *)searchRecommendViewController
{
    if (!_searchRecommendViewController) {
        _searchRecommendViewController = [[SearchDestinationRecommendViewController alloc] init];
        _searchRecommendViewController.delegate = self;
        _searchRecommendViewController.poiType = _searchPoiType;
    }
    return _searchRecommendViewController;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self.searchBar endEditing:YES];
    [super touchesEnded:touches withEvent:event];
    if (self.dataSource.count == 0) {
        self.tableView.hidden = YES;
        self.searchRecommendViewController.view.hidden = NO;
    }
}


#pragma mark - private Methods

- (void)showTableViewHeader
{
    NSString *descriptionStr = [_descriptionOfSerachText objectForKey:@"desc"];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100)];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 24);
    NSUInteger len = [descriptionStr length];
    
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:descriptionStr];
    [desc addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, len)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.lineSpacing = 5;
    [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, len)];
    [btn setAttributedTitle:desc forState:UIControlStateNormal];
    
    desc = [[NSMutableAttributedString alloc] initWithAttributedString:desc];
    [desc addAttribute:NSForegroundColorAttributeName value:COLOR_DISABLE range:NSMakeRange(0, len)];
    [btn setAttributedTitle:desc forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(showIntruductionOfCity) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.numberOfLines = 2;
    
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(btn.bounds.size.width-109, btn.bounds.size.height-31, 100, 20)];
    moreLabel.textColor = APP_THEME_COLOR;
    moreLabel.font = [UIFont systemFontOfSize:13.0];
    if (_searchPoiType == kRestaurantPoi) {
        moreLabel.text = @"全部美食攻略>";
    } else if (_searchPoiType == kShoppingPoi) {
        moreLabel.text = @"全部购物攻略>";
    } else {
        moreLabel.text = @"全文>";
    }
    [btn addSubview:moreLabel];
    self.tableView.tableHeaderView = btn;

}

- (void)hideTableViewHeaderView
{
    self.tableView.tableHeaderView = nil;
}

- (void)showIntruductionOfCity
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    if (_searchPoiType == kRestaurantPoi) {
        webCtl.titleStr = @"美食攻略";
        
    } else if (_searchPoiType == kShoppingPoi) {
        webCtl.titleStr = @"购物攻略";
        
    }
    webCtl.urlStr = [_descriptionOfSerachText objectForKey:@"detailUrl"];
    webCtl.hideToolBar = YES;
    [self.navigationController pushViewController:webCtl animated:YES];
}
/**
 *  开始搜索
 */
- (void)loadDataSourceWithKeyWord:(NSString *)keyWord
{
    self.tableView.hidden = NO;
    self.searchRecommendViewController.view.hidden = YES;
    
    __weak typeof(SearchDestinationViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    _keyWord = keyWord;
    
    NSInteger searchCount = 0;
    if (_searchPoiType == 0) {
        searchCount = 5;
    } else {
        searchCount = 20;
    }
    
    if (_searchPoiType == kRestaurantPoi || _searchPoiType == kShoppingPoi) {
        _descriptionOfSerachText = nil;
        [PoiManager asyncGetDescriptionOfSearchText:_keyWord andPoiType:_searchPoiType completionBlock:^(BOOL isSuccess, NSDictionary *descriptionDic) {
            if (isSuccess && descriptionDic.count) {
                _descriptionOfSerachText = descriptionDic;
                [self showTableViewHeader];
            } else {
                [self hideTableViewHeaderView];
            }
            [PoiManager searchPoiWithKeyword:_keyWord andSearchCount:searchCount andPoiType:_searchPoiType completionBlock:^(BOOL isSuccess, NSArray *searchResultList) {
                if (isSuccess) {
                    [self.dataSource removeAllObjects];
                    self.dataSource = [searchResultList mutableCopy];
                    if (self.dataSource.count>0) {
                        [self.tableView reloadData];
                    } else {
                        NSString *searchStr = [NSString stringWithFormat:@"没有找到“%@”的相关结果", _keyWord];
                        [SVProgressHUD showHint:searchStr];
                    }
                }
                [hud hideTZHUD];
            }];

        }];
    } else {
        [PoiManager searchPoiWithKeyword:_keyWord andSearchCount:searchCount andPoiType:_searchPoiType completionBlock:^(BOOL isSuccess, NSArray *searchResultList) {
            if (isSuccess) {
                [self.dataSource removeAllObjects];
                self.dataSource = [searchResultList mutableCopy];
                if (self.dataSource.count>0) {
                    [self.tableView reloadData];
                } else {
                    NSString *searchStr = [NSString stringWithFormat:@"没有找到“%@”的相关结果", _keyWord];
                    [SVProgressHUD showHint:searchStr];
                }
            }
            [hud hideTZHUD];
        }];
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
    return 119;
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

// TODO:- 修改这的cell
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
        
        cell.ratingView.rating = poi.rating;
        cell.tagsArray = poi.style;
        
        NSLog(@"rating %f",poi.rating);
        
    } else {
        TaoziImage *image = [poi.images firstObject];
        [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
        cell.titleLabel.text = poi.zhName;
        cell.tagsArray = @[];
        cell.ratingView.rating = 0;
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
        CityDetailViewController *ctl = [[CityDetailViewController alloc] init];
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

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar endEditing:YES];
    [self.searchRecommendViewController addSearchHistoryText:searchBar.text];
    [self loadDataSourceWithKeyWord:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self.dataSource removeAllObjects];
        [_tableView reloadData];
        _tableView.hidden = YES;
        _searchRecommendViewController.view.hidden = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (_isRootViewController) {
        [_searchBar endEditing:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark- SearchDestinationRecommendDelegate

- (void)didSelectItemWithSearchText:(NSString *)searchText
{
    [_searchBar endEditing:YES];
    [self loadDataSourceWithKeyWord:searchText];
    _searchBar.text = searchText;
}

#pragma mark - TaoziMessageSendDelegate

/**
 *  用户确定发送景点给朋友
 *
 *  @param chatCtl
 */
- (void)sendSuccess:(ChatViewController *)chatCtl
{
    [self dismissPopup];
    [SVProgressHUD showSuccessWithStatus:@"已发送~"];
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






