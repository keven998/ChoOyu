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
#import "RestaurantsOfCityViewController.h"
#import "ShoppingOfCityViewController.h"

@interface CityDetailTableViewController ()

@property (nonatomic, strong) CityPoi *cityPoi;
@property (nonatomic, strong) CityHeaderView *cityHeaderView;

@end

@implementation CityDetailTableViewController

static NSString * const reuseIdentifier = @"travelNoteCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"TravelNoteTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self loadCityData];
}

- (void)updateView
{
    self.tableView.backgroundColor = UIColorFromRGB(0xeeeeee);
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"CityHeaderView" owner:nil options:nil];
    _cityHeaderView = [nibView firstObject];
    _cityHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, _cityHeaderView.frame.size.height);
    _cityHeaderView.title = _cityPoi.zhName;
    _cityHeaderView.cityImage = _cityPoi.cover;
    _cityHeaderView.desc = _cityPoi.desc;
    _cityHeaderView.timeCost = _cityPoi.timeCost;
    _cityHeaderView.travelMonth = _cityPoi.travelMonth;
    [_cityHeaderView.spotBtn addTarget:self action:@selector(viewSpots:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.restaurantBtn addTarget:self action:@selector(viewRestaurants:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.shoppingBtn addTarget:self action:@selector(viewShopping:) forControlEvents:UIControlEventTouchUpInside];

    self.tableView.tableHeaderView = _cityHeaderView;
    [self.tableView reloadData];
}

- (void)loadCityData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *requsetUrl = [NSString stringWithFormat:@"%@53aa9a6410114e3fd47833bd", API_GET_CITYDETAIL];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:3] forKey:@"noteCnt"];
    
    [SVProgressHUD show];
    
#warning 测试数据
    [self updateView];
   
    
    //获取城市信息
    [manager GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _cityPoi = [[CityPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
    }];

}

#pragma mark - IBAction Methods

- (IBAction)viewSpots:(id)sender
{
    
}

- (IBAction)viewRestaurants:(id)sender
{
    RestaurantsOfCityViewController *restaurantOfCityCtl = [[RestaurantsOfCityViewController alloc] init];
#warning 测试数据
    _cityPoi = [[CityPoi alloc] initWithJson:@{}];
    _cityPoi.zhName = @"大阪";
    _cityPoi.cityId = @"53aa9a6410114e3fd47833bd";
    _cityPoi.restaurants = [[RestaurantsOfCity alloc] initWithJson:@{}];
    restaurantOfCityCtl.currentCity = _cityPoi;
    
    
    restaurantOfCityCtl.cities = @[_cityPoi];
    [self.navigationController pushViewController:restaurantOfCityCtl animated:YES];
}

- (IBAction)viewShopping:(id)sender
{
    ShoppingOfCityViewController *shoppingOfCityCtl = [[ShoppingOfCityViewController alloc] init];
    [self.navigationController pushViewController:shoppingOfCityCtl animated:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.cityPoi.travelNotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TravelNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    TravelNote *travelNote = [self.cityPoi.travelNotes objectAtIndex:indexPath.row];
    cell.travelNoteImage = travelNote.cover;
    cell.title = travelNote.title;
    cell.desc = travelNote.desc;
    cell.authorName = travelNote.authorName;
    cell.authorAvatar = travelNote.authorAvatar;
    cell.resource = travelNote.source;
//    cell.time = travelNote.publishDate;
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    TravelNote *travelNote = [self.cityPoi.travelNotes objectAtIndex:indexPath.row];
    
}

@end






