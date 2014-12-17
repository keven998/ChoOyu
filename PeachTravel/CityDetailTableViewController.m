//
//  CityDetailTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityDetailTableViewController.h"
#import "CityHeaderView.h"
#import "TravelNoteTableViewCell.h"
#import "CityPoi.h"
#import "TravelNote.h"
#import "PoisOfCityViewController.h"
#import "AccountManager.h"
#import "SuperWebViewController.h"
#import "TravelNoteListViewController.h"
#import "TravelNoteDetailViewController.h"

@interface CityDetailTableViewController () <UITableViewDataSource, UITableViewDelegate, CityHeaderViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CityPoi *cityPoi;
@property (nonatomic, strong) CityHeaderView *cityHeaderView;
@property (nonatomic, strong) UIView *tableHeaderView;

@end

@implementation CityDetailTableViewController

static NSString * const reuseIdentifier = @"travelNoteCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"TravelNoteTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    [self loadCityData];
}

- (void)updateView
{
    self.navigationItem.title = _cityPoi.zhName;
    _cityHeaderView = [[CityHeaderView alloc] init];
    _cityHeaderView.delegate = self;
    _cityHeaderView.backgroundColor = APP_PAGE_COLOR;
    [_cityHeaderView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    NSLog(@"%@",NSStringFromCGRect(_cityHeaderView.frame));
    _cityHeaderView.cityPoi = _cityPoi;
    _tableHeaderView = [[UIView alloc] initWithFrame:_cityHeaderView.frame];
    NSLog(@"%@",NSStringFromCGRect(_cityHeaderView.frame));
    self.tableView.tableHeaderView = _tableHeaderView;
    [self.tableView addSubview:_cityHeaderView];
    [_cityHeaderView.favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showSpotsBtn addTarget:self action:@selector(viewSpots:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showRestaurantsBtn addTarget:self action:@selector(viewRestaurants:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showShoppingBtn addTarget:self action:@selector(viewShopping:) forControlEvents:UIControlEventTouchUpInside];

    [self.tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 64, self.view.frame.size.width-22, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        [_tableView setContentInset:UIEdgeInsetsMake(10, 0, 0, 0)];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (void)loadCityData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    NSString *requsetUrl = [NSString stringWithFormat:@"%@5473ccd7b8ce043a64108c46", API_GET_CITYDETAIL];
    
    [SVProgressHUD show];
    
    //获取城市信息
    [manager GET:requsetUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _cityPoi = [[CityPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
            [self loadTravelNoteOfCityData];
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
    }];
}

/**
 *  当加载完城市详情后开始加载城市的攻略内容
 */
- (void)loadTravelNoteOfCityData
{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:3] forKey:@"pageSize"];
    [params setObject:_cityPoi.cityId forKey:@"locId"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"page"];
    
    [manager GET:API_SEARCH_TRAVELNOTE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _cityPoi.travelNotes = [responseObject objectForKey:@"result"];
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus:@"加载失败"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
    }];

}

/**
 *  实现父类的发送 poi 到桃talk 的值传递
 *
 *  @param taoziMessageCtl
 */
- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = _cityPoi.cityId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[_cityPoi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = _cityPoi.desc;
    taoziMessageCtl.messageName = _cityPoi.zhName;
    taoziMessageCtl.messageTimeCost = _cityPoi.timeCostDesc;
    taoziMessageCtl.descLabel.text = _cityPoi.desc;
    taoziMessageCtl.chatType = TZChatTypeCity;
}

#pragma mark - IBAction Methods

- (IBAction)favorite:(id)sender
{
    _cityHeaderView.favoriteBtn.userInteractionEnabled = NO;
    [super asyncFavorite:_cityPoi.cityId poiType:@"localities" isFavorite:!_cityPoi.isMyFavorite completion:^(BOOL isSuccess) {
        _cityHeaderView.favoriteBtn.userInteractionEnabled = YES;
        if (isSuccess) {
            _cityPoi.isMyFavorite = !_cityPoi.isMyFavorite;
            NSString *imageName = _cityPoi.isMyFavorite ? @"ic_favorite.png":@"ic_unFavorite.png";
            [_cityHeaderView.favoriteBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        } else {
            
        }
    }];
}

- (IBAction)viewSpots:(id)sender
{
    SuperWebViewController *funOfCityWebCtl = [[SuperWebViewController alloc] init];
    funOfCityWebCtl.urlStr = FUN_CITY_HTML;
    funOfCityWebCtl.titleStr = _cityPoi.zhName;
    [self.navigationController pushViewController:funOfCityWebCtl animated:YES];
}

- (IBAction)viewRestaurants:(id)sender
{
    NSLog(@"应该进入城市的美食信息");

    PoisOfCityViewController *restaurantOfCityCtl = [[PoisOfCityViewController alloc] init];
#warning 测试数据
    _cityPoi.cityId = @"53aa9a6410114e3fd47833bd";
    restaurantOfCityCtl.shouldEdit = NO;
    restaurantOfCityCtl.currentCity = _cityPoi;
    restaurantOfCityCtl.poiType = TripRestaurantPoi;
    
    [self.navigationController pushViewController:restaurantOfCityCtl animated:YES];
}

- (IBAction)viewShopping:(id)sender
{
    NSLog(@"应该进入城市的购物信息");

    PoisOfCityViewController *shoppingOfCityCtl = [[PoisOfCityViewController alloc] init];
    _cityPoi.cityId = @"53aa9a6410114e3fd47833bd";
    shoppingOfCityCtl.shouldEdit = NO;
    shoppingOfCityCtl.currentCity = _cityPoi;
    shoppingOfCityCtl.poiType = TripShoppingPoi;
    
    [self.navigationController pushViewController:shoppingOfCityCtl animated:YES];
}

- (IBAction)showMoreTravelNote:(id)sender
{
    TravelNoteListViewController *travelListCtl = [[TravelNoteListViewController alloc] init];
    travelListCtl.isSearch = NO;
    travelListCtl.cityId = self.cityPoi.cityId;
    [self.navigationController pushViewController:travelListCtl animated:YES];
}

#pragma mark - CityHeaderViewDelegate

- (void)updateCityHeaderView
{
    _tableHeaderView = [[UIView alloc] initWithFrame:_cityHeaderView.frame];
    [self.tableView beginUpdates];
    [self.tableView setTableHeaderView:_tableHeaderView];
    [self.tableView endUpdates];
    [self.tableView bringSubviewToFront:_cityHeaderView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.cityPoi.travelNotes.count >= 1) {
        return 1;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 149.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30.0;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cityPoi.travelNotes.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    [btn setImage:[UIImage imageNamed:@"ic_standard_travelnote.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"ic_standard_travelnote.png"] forState:UIControlStateHighlighted];

    [btn setTitle:@"精选游记" forState:UIControlStateNormal];
    [btn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [btn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];

    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn.backgroundColor = [UIColor whiteColor];
    
    UIButton *moreTravelNoteBtn = [[UIButton alloc] initWithFrame:CGRectMake(btn.frame.size.width-48, 0, 40, 30)];
    [moreTravelNoteBtn setTitle:@"更多游记" forState:UIControlStateNormal];
    [moreTravelNoteBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    moreTravelNoteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    moreTravelNoteBtn.titleLabel.font = [UIFont systemFontOfSize:10.0];
    
    [moreTravelNoteBtn addTarget:self action:@selector(showMoreTravelNote:) forControlEvents:UIControlEventTouchUpInside];
    
    [btn addSubview:moreTravelNoteBtn];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, btn.frame.size.width, 1)];
    spaceView.backgroundColor = APP_DIVIDER_COLOR;
    [btn addSubview:spaceView];

    return btn;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TravelNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    TravelNote *travelNote = [self.cityPoi.travelNotes objectAtIndex:indexPath.row];
    cell.travelNoteImage = travelNote.cover;
    cell.title = travelNote.title;
    cell.desc = travelNote.summary;
    cell.authorName = travelNote.authorName;
    cell.authorAvatar = travelNote.authorAvatar;
    cell.resource = travelNote.source;
    cell.time = travelNote.publishDateStr;
    cell.canSelect = NO;
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TravelNote *travelNote = [self.cityPoi.travelNotes objectAtIndex:indexPath.row];
    TravelNoteDetailViewController *travelNoteCtl = [[TravelNoteDetailViewController alloc] init];
    travelNoteCtl.urlStr = travelNote.sourceUrl;
    travelNoteCtl.title = travelNote.title;
    
    travelNoteCtl.travelNoteTitle = travelNote.title;
    travelNoteCtl.desc = travelNote.summary;
    travelNoteCtl.travelNoteCover = travelNote.cover;
    travelNoteCtl.travelNoteId = travelNote.travelNoteId;
    [self.navigationController pushViewController:travelNoteCtl animated:YES];
    
}



@end






