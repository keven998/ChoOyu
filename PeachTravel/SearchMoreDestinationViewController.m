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

@interface SearchMoreDestinationViewController () <UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, TaoziMessageSendDelegate>

@property (nonatomic, strong) UIButton *positionBtn;
@property (nonatomic, strong) UITableView *tableView;
/**
 *  保存搜索结果
 */
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) CityDestinationPoi *localCity;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;

/**
 *  联想的城市数据
 */
@property (nonatomic, strong) NSMutableArray *searchResultArray;

@end

@implementation SearchMoreDestinationViewController

static NSString *reusableCellIdentifier = @"searchResultCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = @"发送地点";
    if (_poiType == kHotelPoi || _poiType == kRestaurantPoi || _poiType == kShoppingPoi) {
        UIView *positionView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, 35)];
        positionView.backgroundColor = [APP_THEME_COLOR colorWithAlphaComponent:0.5];

        _positionBtn = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-150-30, 0, 150, 35)];
        _positionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_positionBtn setTitle:@"未选择" forState:UIControlStateNormal];
        [_positionBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        _positionBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [_positionBtn addTarget:self action:@selector(beginSearch:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *extender = [[UIImageView alloc] initWithFrame:CGRectMake(kWindowWidth-20, 12.5, 6, 10)];
        [extender setImage:[UIImage imageNamed:@"cell_accessory_pink.png"]];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 0, 100, 35)];
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = @"所在城市";
        [positionView addSubview:extender];
        [positionView addSubview:_positionBtn];
        [positionView addSubview:titleLabel];
        [self.view addSubview:positionView];
        
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40, 38)];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.delegate = self;
        [_searchBar setPlaceholder:@"请输入城市名或拼音"];
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.translucent = YES;
        _searchBar.showsCancelButton = YES;
        _searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
        _searchController.active = NO;
        _searchController.searchResultsDataSource = self;
        _searchController.searchResultsDelegate = self;
        [_searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"suggestCell"];
        
        [self.view addSubview:_searchBar];

    }
    [self.view addSubview:self.tableView];
    [self loadDataSourceWithKeyWord:_keyWord];
   
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
}


/**
 *  开始从网络上加载数据
 */
- (void)loadDataSourceWithKeyWord:(NSString *)keyWord
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:keyWord forKey:@"keyWord"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:_poiTypeDesc];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params safeSetObject:_localCity.cityId forKey:@"locId"];
     __weak typeof(SearchMoreDestinationViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf.navigationController];
    
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self analysisData:[responseObject objectForKey:@"result"]];
              
        } else {
            [SVProgressHUD showHint:@"请求也是失败了"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
    }];
    
}

- (void)analysisData:(id)json
{
    [self.dataSource removeAllObjects];
    for (id dic in [json objectForKey:_poiTypeDesc]) {
        TripPoi *poi = [[TripPoi alloc] initWithJson:dic];
        poi.poiType = kSpotPoi;
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
    headerView.font = [UIFont systemFontOfSize:12.0];
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
        headerView.font = [UIFont systemFontOfSize:12.0];
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
        TripPoi *poi = [self.dataSource objectAtIndex:indexPath.row];
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
        TripPoi *poi = [self.dataSource objectAtIndex:indexPath.row];
        
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
        
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
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
