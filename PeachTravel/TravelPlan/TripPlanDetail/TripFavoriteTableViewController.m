//
//  TripFavoriteTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/11/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "TripFavoriteTableViewController.h"
#import "RestaurantsListViewController.h"
#import "ShoppingListViewController.h"

@interface TripFavoriteTableViewController ()

@property (nonatomic, strong)NSMutableDictionary * showDic;

@end

@implementation TripFavoriteTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 70;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.separatorColor = COLOR_LINE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"page_lxp_plan_favorite"];
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_lxp_plan_favorite"];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:@"Cell"];
    cell.textLabel.textColor = COLOR_TEXT_I;
    cell.detailTextLabel.textColor = COLOR_TEXT_II;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"collect_food.png"];
        cell.textLabel.text = @"美食";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld个收集的美食", (long)_tripDetail.restaurantsList.count];
    }
    else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"collect_shopping.png"];
        cell.textLabel.text = @"购物";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld个收集的购物", (long)_tripDetail.shoppingList.count];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"tab_item_trip_favorite"];
    if (indexPath.row == 0) {
        [MobClick event:@"cell_item_plan_favorite_delicy"];
        RestaurantsListViewController *ctl = [[RestaurantsListViewController alloc] init];
        ctl.canEdit = _canEdit;
        ctl.tripDetail = _tripDetail;
        [self.frostedViewController.navigationController pushViewController:ctl animated:YES];
    } else {
        [MobClick event:@"cell_item_plan_favorite_shopping"];
        ShoppingListViewController *ctl = [[ShoppingListViewController alloc] init];
        ctl.tripDetail = _tripDetail;
        ctl.canEdit = _canEdit;
        [self.frostedViewController.navigationController pushViewController:ctl animated:YES];
    }
    
}

@end
