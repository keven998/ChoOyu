//
//  CityListTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "CityListTableViewController.h"

@interface CityListTableViewController ()

@end

@implementation CityListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cityCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_cityDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *city = [_cityDataSource objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
    cell.textLabel.text = [city objectForKey:@"name"];
    if ([[city objectForKey:@"childCities"] count] > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *city = [_cityDataSource objectAtIndex:indexPath.row];
    if ([[city objectForKey:@"childCities"] count] > 0) {
        CityListTableViewController *cityListCtl = [[CityListTableViewController alloc] init];
        cityListCtl.cityDataSource = [city objectForKey:@"childCities"];
        [self.navigationController pushViewController:cityListCtl animated:YES];
    } else {
        NSLog(@"我选择了%@", [city objectForKey:@"name"]);
    }
    
}

@end
