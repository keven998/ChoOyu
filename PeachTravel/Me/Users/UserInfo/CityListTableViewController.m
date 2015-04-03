//
//  CityListTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "CityListTableViewController.h"

@interface CityListTableViewController () <CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
    NSString *_locationStr;
}

@end

@implementation CityListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cityCell"];
    if (_needUserLocation) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        if (IS_IOS8) {
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager startUpdatingLocation];
    }
    self.navigationItem.title = @"选择居住地";
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
            [SVProgressHUD showHint:@"修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
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
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    label.font = [UIFont systemFontOfSize:14.0];
    label.backgroundColor = APP_PAGE_COLOR;
    if (_needUserLocation) {
        if (section == 0) {
            label.text = @"   定位获取的位置";
        } else {
            label.text = @"   国内全部城市";
        }
    } else {
        label.text = @"   国内全部城市";
    }
    return label;
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
            } else {
                [SVProgressHUD showHint:@"定位还木有完成呢。"];
            }

        } else {
            NSDictionary *city = [_cityDataSource objectAtIndex:indexPath.row];
            if ([[city objectForKey:@"childCities"] count] > 0) {
                CityListTableViewController *cityListCtl = [[CityListTableViewController alloc] init];
                cityListCtl.cityDataSource = [city objectForKey:@"childCities"];
                [self.navigationController pushViewController:cityListCtl animated:YES];
            } else {
                NSLog(@"我选择了%@", [city objectForKey:@"name"]);
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
            NSLog(@"我选择了%@", [city objectForKey:@"name"]);
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
    CLLocation *location = [locations firstObject];
    NSLog(@"oh my god我被定位到了：%f, %f", location.coordinate.latitude, location.coordinate.longitude);
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
