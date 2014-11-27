//
//  AddPoiTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AddPoiTableViewController.h"
#import "AddSpotTableViewCell.h"
#import "SINavigationMenuView.h"
#import "CityDestinationPoi.h"
#import "TripDetail.h"
#import "RestaurantOfCityTableViewCell.h"

@interface AddPoiTableViewController () <SINavigationMenuDelegate>

@property (nonatomic) NSUInteger currentListTypeIndex;
@property (nonatomic) NSUInteger currentCityIndex;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) SINavigationMenuView *sortPoiView;
@property (nonatomic, strong) SINavigationMenuView *sortCityView;

@property (nonatomic, copy) NSString *requestUrl;


@end

@implementation AddPoiTableViewController

static NSString *addSpotCellIndentifier = @"addSpotCell";
static NSString *addRestaurantCellIndentifier = @"restaurantOfCityCell";
static NSString *addShoppingCellIndentifier = @"shoppingOfCityCell";
static NSString *addHotelCellIndentifier = @"addHotelCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    _urlArray = @[API_GET_SPOTLIST_CITY, API_GET_RESTAURANTSLIST_CITY, API_GET_SHOPPINGLIST_CITY, API_GET_HOTELLIST_CITY];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:addSpotCellIndentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RestaurantOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:addRestaurantCellIndentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShoppingOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:addShoppingCellIndentifier];
//    [self.tableView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:addSpotCellIndentifier];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:UIColorFromRGB(0xee528c) forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(addFinish:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem1 = [[UIBarButtonItem alloc] initWithCustomView:self.sortPoiView];
    UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithCustomView:finishBtn];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sortCityView];
    self.navigationItem.rightBarButtonItems = @[barItem2, barItem1];
    CityDestinationPoi *firstDestination = [_tripDetail.destinations firstObject];
//    _requestUrl = [NSString stringWithFormat:@"%@%@", API_GET_SPOTLIST_CITY ,firstDestination.cityId];
        _requestUrl = [NSString stringWithFormat:@"%@53aa9a6410114e3fd47833bd", API_GET_SPOTLIST_CITY];
}

#pragma mark - setter & getter

- (SINavigationMenuView *)sortPoiView
{
    if (!_sortPoiView) {
        CGRect frame = CGRectMake(0, 0, 50, 30);
        _sortPoiView = [[SINavigationMenuView alloc] initWithFrame:frame title:@"筛选"];
        [_sortPoiView displayMenuInView:self.navigationController.view];
        _sortPoiView.items = @[@"景点", @"美食", @"购物", @"酒店"];
        _sortPoiView.delegate = self;
    }
    return _sortPoiView;
}

- (SINavigationMenuView *)sortCityView
{
    if (!_sortCityView) {
        CGRect frame = CGRectMake(0, 0, 50, 30);
        _sortCityView = [[SINavigationMenuView alloc] initWithFrame:frame title:@"筛选"];
        [_sortCityView displayMenuInView:self.navigationController.view];
        _sortCityView.items = @[@"安顺", @"大阪", @"长岛", @"烟台"];
        _sortCityView.delegate = self;
    }
    return _sortCityView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

#pragma mark - IBAction Methods

- (IBAction)addFinish:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addPoi:(UIButton *)sender
{
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    TripPoi *poi = [self.dataSource objectAtIndex:sender.tag];
    [oneDayArray addObject:poi];
    [_delegate finishEdit];
}

#pragma mark - Private Methods

- (void)loadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [SVProgressHUD show];
    
    //获取列表信息
    [manager GET:_requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            for (id poiDic in [responseObject objectForKey:@"result"]) {
                [self.dataSource addObject:[[TripPoi alloc] initWithJson:poiDic]];
                [self.tableView reloadData];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
    }];
    
}


#pragma mark - SINavigationMenuDelegate

- (void)didSelectItemAtIndex:(NSUInteger)index withSender:(id)sender
{
    if ([sender isEqual:self.sortPoiView]) {
        if (_currentListTypeIndex != index) {
            _currentListTypeIndex = index;
            CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
//            _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
            _requestUrl = [NSString stringWithFormat:@"%@53aa9a6410114e3fd47833bd", _urlArray[_currentListTypeIndex]];
            [self.dataSource removeAllObjects];
            [self loadData];
        }
        
    } else {
        if (_currentCityIndex != index) {
            _currentCityIndex = index;
            CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentListTypeIndex];
//            _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
            _requestUrl = [NSString stringWithFormat:@"%@53aa9a6410114e3fd47833bd", _urlArray[_currentListTypeIndex]];
            [self.dataSource removeAllObjects];
            [self loadData];
        }
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 136.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TripPoi *poi = [self.dataSource objectAtIndex:indexPath.row];
    if (poi.poiType == TripSpotPoi) {
        AddSpotTableViewCell *addSpotCell = [tableView dequeueReusableCellWithIdentifier:addSpotCellIndentifier];
        addSpotCell.tripPoi = poi;
        addSpotCell.addBtn.tag = indexPath.row;
        [addSpotCell.addBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        return addSpotCell;
    }
    
    if (poi.poiType == TripRestaurantPoi) {
        RestaurantPoi *restaurantPoi = [[RestaurantPoi alloc] init];
        restaurantPoi.restaurantId = poi.poiId;
        restaurantPoi.zhName = poi.zhName;
        restaurantPoi.enName = poi.enName;
        restaurantPoi.desc = poi.desc;
        restaurantPoi.priceDesc = poi.priceDesc;
        restaurantPoi.commentCount = 0;
        restaurantPoi.telephone = poi.telephone;
        restaurantPoi.images = poi.images;
        RestaurantOfCityTableViewCell *restaurantCell = [tableView dequeueReusableCellWithIdentifier:addRestaurantCellIndentifier forIndexPath:indexPath];
        restaurantCell.restaurantPoi = restaurantPoi;
        restaurantCell.addBtn.tag = indexPath.row;
        [restaurantCell.addBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        return restaurantCell;
    }
    
    if (poi.poiType == TripShoppingPoi) {
        
    }
    if (poi.poiType == TripHotelPoi) {
        
    }
    return nil;
}

@end
