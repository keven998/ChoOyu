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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 70;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:@"Cell"];
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"collect_food.png"];
        cell.textLabel.text = @"美食";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld个收藏", _tripDetail.restaurantsList.count];
    }
    else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"collect_shopping.png"];
        cell.textLabel.text = @"购物";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld个收藏", _tripDetail.shoppingList.count];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        RestaurantsListViewController *ctl = [[RestaurantsListViewController alloc] init];
        ctl.canEdit = _canEdit;
        ctl.tripDetail = _tripDetail;
        [self.frostedViewController.navigationController pushViewController:ctl animated:YES];
    } else {
        ShoppingListViewController *ctl = [[ShoppingListViewController alloc] init];
        ctl.tripDetail = _tripDetail;
        ctl.canEdit = _canEdit;
        [self.frostedViewController.navigationController pushViewController:ctl animated:YES];
    }
    
}

@end
