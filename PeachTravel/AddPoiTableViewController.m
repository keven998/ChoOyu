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

@interface AddPoiTableViewController () <SINavigationMenuDelegate>

@property (nonatomic) NSUInteger currentListTypeIndex;
@property (nonatomic) NSUInteger currentCityIndex;
@property (nonatomic, strong) NSArray *urlArray;

@property (nonatomic, strong) SINavigationMenuView *sortPoiView;
@property (nonatomic, strong) SINavigationMenuView *sortCityView;

@property (nonatomic, copy) NSString *requestUrl;


@end

@implementation AddPoiTableViewController

static NSString *addSpotCellIndentifier = @"addSpotCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    _urlArray = @[API_GET_SPOTLIST_CITY, API_GET_RESTAURANTSLIST_CITY, API_GET_SHOPPINGLIST_CITY, API_GET_HOTELLIST_CITY];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:addSpotCellIndentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIButton *finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:UIColorFromRGB(0xee528c) forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(addFinish:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem1 = [[UIBarButtonItem alloc] initWithCustomView:self.sortPoiView];
    UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithCustomView:finishBtn];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sortCityView];
    self.navigationItem.rightBarButtonItems = @[barItem2, barItem1];
    CityDestinationPoi *firstDestination = [_tripDetail.destinations firstObject];
    _requestUrl = [NSString stringWithFormat:@"%@%@", API_GET_SPOTLIST_CITY ,firstDestination.cityId];
    [self loadData];
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

#pragma mark - IBAction Methods

- (IBAction)addFinish:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
            CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:index];
            _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
            [self loadData];
        }
        
    } else {
        if (_currentCityIndex != index) {
            _currentCityIndex = index;
            CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:index];
            _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
            [self loadData];
        }
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddSpotTableViewCell *addSpotCell = [tableView dequeueReusableCellWithIdentifier:addSpotCellIndentifier];
    return addSpotCell;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
