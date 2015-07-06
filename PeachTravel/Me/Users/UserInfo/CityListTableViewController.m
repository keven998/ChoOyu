//
//  CityListTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "CityListTableViewController.h"

@interface CityListTableViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
    CLLocationManager *_locationManager;
    NSString *_locationStr;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CityListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选择现住地";
    
    if (self.navigationController.childViewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
        self.navigationItem.rightBarButtonItem = nil;
        
    } else {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(dismiss)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 48, 30)];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorColor = APP_BORDER_COLOR;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60;
    [self.view addSubview:_tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cityCell"];
    
    if (_needUserLocation) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        if (IS_IOS8) {
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager startUpdatingLocation];
    }
}

- (void)dismiss
{
    if (self.navigationController.childViewControllers.count <= 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateUserResidence
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInView:self.view];
    [accountManager asyncChangeResidence:_locationStr completion:^(BOOL isSuccess, NSString *errStr) {
        if (isSuccess) {
            [hud hideTZHUD];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            [SVProgressHUD showHint:@"请求失败"];
            [hud hideTZHUD];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_needUserLocation) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_needUserLocation) {
        if (section == 0) {
            return 1;
        } else {
            return [_cityDataSource count];
        }
        
    } else {
        return [_cityDataSource count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (section == 0) {
        return 50;
    }
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, tableView.bounds.size.width, 30)];
        label.font = [UIFont systemFontOfSize:14.0];
        label.backgroundColor = APP_PAGE_COLOR;
        if (_needUserLocation) {
            label.text = @"   定位获取的位置";
        } else {
            label.text = @"   国内全部城市";
        }
        [headerView addSubview:label];
        return headerView;
        
    } else {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        label.font = [UIFont systemFontOfSize:14.0];
        label.backgroundColor = APP_PAGE_COLOR;
        if (_needUserLocation) {
            label.text = @"   国内全部城市";
        } else {
            label.text = @"   国内全部城市";
        }
        return label;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
    if (_needUserLocation) {
        if (indexPath.section == 0) {
            if (_locationStr) {
                cell.textLabel.text = _locationStr;
            } else {
                cell.textLabel.text = @"定位中...";
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        } else {
            NSDictionary *city = [_cityDataSource objectAtIndex:indexPath.row];
            cell.textLabel.text = [city objectForKey:@"name"];
            if ([[city objectForKey:@"childCities"] count] > 0) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
    } else {
        NSDictionary *city = [_cityDataSource objectAtIndex:indexPath.row];
        cell.textLabel.text = [city objectForKey:@"name"];
        if ([[city objectForKey:@"childCities"] count] > 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_needUserLocation) {
        if (indexPath.section == 0) {
            if (_locationStr) {
                [self updateUserResidence];
            }
//            else {
//                [SVProgressHUD showHint:@"定位还木有完成呢。"];
//            }
        } else {
            NSDictionary *city = [_cityDataSource objectAtIndex:indexPath.row];
            if ([[city objectForKey:@"childCities"] count] > 0) {
                CityListTableViewController *cityListCtl = [[CityListTableViewController alloc] init];
                cityListCtl.cityDataSource = [city objectForKey:@"childCities"];
                [self.navigationController pushViewController:cityListCtl animated:YES];
            } else {
                _locationStr = [city objectForKey:@"name"];
                [self updateUserResidence];
            }
        }
        
    } else {
        NSDictionary *city = [_cityDataSource objectAtIndex:indexPath.row];
        if ([[city objectForKey:@"childCities"] count] > 0) {
            CityListTableViewController *cityListCtl = [[CityListTableViewController alloc] init];
            cityListCtl.cityDataSource = [city objectForKey:@"childCities"];
            [self.navigationController pushViewController:cityListCtl animated:YES];
        } else {
            _locationStr = [city objectForKey:@"name"];
            [self updateUserResidence];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
    CLLocation *location = [locations firstObject];
    [self getReverseGeocodeWithLoation:location];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [_locationManager stopUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [_locationManager startUpdatingLocation];
            
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [_locationManager startUpdatingLocation];
            
        default:
            break;
    }
}

- (void)getReverseGeocodeWithLoation:(CLLocation *)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error)
        {
            NSLog(@"failed with error: %@", error);
            return;
        }
        if(placemarks.count > 0)
        {
            CLPlacemark *clPlaceMark = [placemarks firstObject];
            _locationStr = [clPlaceMark.addressDictionary objectForKey:@"City"];
            [self.tableView reloadData];
        }
    }];
}


@end
