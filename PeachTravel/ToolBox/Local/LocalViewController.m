//
//  LocalViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "LocalViewController.h"
#import "DMFilterView.h"
#import "SwipeView.h"
#import "PoisOfCityTableViewCell.h"
#import "AddSpotTableViewCell.h"
#import "PoiSummary.h"

#define LOCAL_PAGE_TITLES       @[@"桃∙景", @"桃∙食", @"桃∙购", @"桃∙宿"]
#define LOCAL_PAGE_NORMALIMAGES       @[@"nearby_ic_tab_spot_normal.png", @"nearby_ic_tab_delicacy_normal.png", @"nearby_ic_tab_shopping_normal.png", @"nearby_ic_tab_stay_normal.png"]
#define LOCAL_PAGE_HIGHLIGHTEDIMAGES       @[@"nearby_ic_tab_spot_select.png", @"nearby_ic_tab_delicacy_select", @"nearby_ic_tab_shopping_select.png", @"nearby_ic_tab_stay_select.png"]

#define PAGE_FUN                0
#define PAGE_FOOD               1
#define PAGE_SHOPPING           2
#define PAGE_STAY               3

@interface LocalViewController ()<DMFilterViewDelegate, SwipeViewDataSource, SwipeViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) DMFilterView *filterView;
@property (nonatomic, strong) SwipeView *swipeView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我身边";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    _filterView = [[DMFilterView alloc]initWithStrings:LOCAL_PAGE_TITLES normatlImages:LOCAL_PAGE_NORMALIMAGES highLightedImages:LOCAL_PAGE_HIGHLIGHTEDIMAGES containerView:self.view];
    _filterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.filterView attachToContainerView];
    [self.filterView setDelegate:self];
    _filterView.backgroundColor = [UIColor whiteColor];
    _filterView.selectedItemBackgroundColor = [UIColor whiteColor];

    _swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, 64.0 + CGRectGetHeight(_filterView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64.0 - CGRectGetHeight(_filterView.frame))];
    _swipeView.dataSource = self;
    _swipeView.delegate = self;
    _swipeView.bounces = NO;
    _swipeView.backgroundColor = [UIColor redColor];
    _swipeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _swipeView.pagingEnabled = YES;
    _swipeView.itemsPerPage = 1;
    [self.view addSubview:_swipeView];
    [self loadData];
}

#pragma mark - getter & getter

- (NSArray *)dataSource
{
    if (!_dataSource) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5; i++) {
            NSMutableArray *oneList = [[NSMutableArray alloc] init];
            [tempArray addObject:oneList];
        }
        _dataSource = tempArray;
    }
    return _dataSource;
}

- (void)loadData {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:3] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"page"];
    [params setObject:[NSNumber numberWithFloat:_lat] forKey:@"lat"];
    [params setObject:[NSNumber numberWithFloat:_lng] forKey:@"lng"];
    
    switch (_currentPage) {
        case PAGE_FUN:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"vs"];
            break;
            
        case PAGE_FOOD:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"restaurant"];
            break;
            
        case PAGE_SHOPPING:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"shopping"];
            break;
            
        case PAGE_STAY:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"hotel"];
            break;
            
        default:
            break;
    }

    [SVProgressHUD show];
    [manager GET:API_NEARBY parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD dismiss];
            [self analysisData:[responseObject objectForKey:@"result"]];
        } else {
            [SVProgressHUD showErrorWithStatus:@"加载失败"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
    }];
    
}

- (void)analysisData:(id)json
{
    NSString *key;
    NSMutableArray *currentList = [self.dataSource objectAtIndex:_currentPage];
    tripPoiType type;
    switch (_currentPage) {
        case PAGE_FUN:
            key = @"vs";
            type = TripSpotPoi;
            break;
        case PAGE_FOOD:
            key = @"restaurant";
            type = TripRestaurantPoi;

            break;
        case PAGE_SHOPPING:
            key = @"shopping";
            type = TripShoppingPoi;

            break;
        case PAGE_STAY:
            key = @"hotel";
            type = TripHotelPoi;

            break;
            
        default:
            break;
    }
    NSArray *dataList = [json objectForKey:key];
    for (id poiDic in dataList) {
        [currentList addObject:[[PoiSummary alloc] initWithJson:poiDic]];
    }
    UITableView *currentTableView =  (UITableView *)[_swipeView viewWithTag:1];
    if (currentTableView) {
        [currentTableView reloadData];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (_currentPage) {
//        case PAGE_FOOD:
//            
//            break;
//            
//        default:
//            break;
//    }
    return 185.0;
}


#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *datas = [self.dataSource objectAtIndex:_currentPage];
    return datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_currentPage == PAGE_FUN) {
        AddSpotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addSpotCell"];
        PoiSummary *poi = [[_dataSource objectAtIndex:_currentPage] objectAtIndex:indexPath.row];
        TripPoi *trippoi = [[TripPoi alloc] init];
        trippoi.poiId = poi.poiId;
        trippoi.images = poi.images;
        trippoi.zhName = poi.zhName;
        trippoi.enName = poi.enName;
        trippoi.desc = poi.desc;
        trippoi.rating = poi.rating;
        trippoi.timeCost = poi.timeCost;
        trippoi.lat = poi.lat;
        trippoi.lng = poi.lng;
        cell.addBtn.tag = indexPath.row;
        cell.shouldEdit = NO;
        return cell;
    }
    PoisOfCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poisOfCity"];
    cell.poi = [[_dataSource objectAtIndex:_currentPage] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - SwipeViewDataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return LOCAL_PAGE_TITLES.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UITableView *tbView = nil;
    _currentPage = index;
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tbView = [[UITableView alloc] initWithFrame:view.bounds];
        tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tbView.contentInset = UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0);
        tbView.dataSource = self;
        tbView.delegate = self;
        tbView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tbView.tag = 1;
        tbView.backgroundColor = APP_PAGE_COLOR;
        [view addSubview:tbView];
        if (index == PAGE_FUN) {
            [tbView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:@"addSpotCell"];
        } else {
            [tbView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:@"poisOfCity"];
        }
    
    } else {
        tbView = (UITableView *)[view viewWithTag:1];
        if (index == PAGE_FUN) {
            [tbView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:@"addSpotCell"];
        } else {
            [tbView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:@"poisOfCity"];
        }
        [tbView reloadData];
    }
    return view;
}


#pragma mark - SwipeViewDelegate

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    _currentPage = swipeView.currentPage;
    [_filterView setSelectedIndex:_currentPage];
    if (![[self.dataSource objectAtIndex:_currentPage] count]) {
        NSLog(@"点击我，我要加载数据") ;
        [self loadData];
    }

}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return swipeView.bounds.size;
}

#pragma mark - DMFilterViewDelegate

- (void)filterView:(DMFilterView *)filterView didSelectedAtIndex:(NSInteger)index {
    [_swipeView setCurrentPage:index];
    _currentPage = index;
}


@end
