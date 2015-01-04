//
//  RestaurantsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantsListViewController.h"
#import "DKCircleButton.h"
#import "CommonPoiListTableViewCell.h"
#import "DestinationsView.h"
#import "PoisOfCityTableViewCell.h"
#import "CityDestinationPoi.h"
#import "DestinationUnit.h"
#import "CityDetailTableViewController.h"
#import "RestaurantDetailViewController.h"
#import "PoisOfCityTableViewController.h"

@interface RestaurantsListViewController () <UITableViewDataSource, UITableViewDelegate, PoisOfCityDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DKCircleButton *editBtn;
@property (strong, nonatomic) UIView *tableViewFooterView;

@end

@implementation RestaurantsListViewController

static NSString *restaurantListReusableIdentifier = @"commonPoiListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.tableView];
    _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-110, 40, 40)];
   
    [_editBtn addTarget:self action:@selector(editTrip:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView reloadData];
    [self.view addSubview:_editBtn];
    if (!_tripDetail || !_canEdit) {
        _editBtn.hidden = YES;
    } else {
        if (_tripDetail.restaurantsList.count > 0) {
            [self.tableView setEditing:NO];
            _editBtn.backgroundColor = UIColorFromRGB(0x797979);
            [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit"] animated:YES];
        } else {
            [_editBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (UIView *subview in self.view.subviews) {
        if ([subview isEqual:_destinationsHeaderView]) {
            return;
        }
    }
    NSLog(@"我应该加载目的地列表");
    [self.view addSubview:_destinationsHeaderView];
}


#pragma mark - setter & getter

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    [_tableView reloadData];
    [self updateDestinationsHeaderView];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 64, self.view.frame.size.width-22, self.view.frame.size.height-64 - 50)];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        [self.tableView registerNib:[UINib nibWithNibName:@"CommonPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:restaurantListReusableIdentifier];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 55)];

    }
    return _tableView;
}

- (UIView *)tableViewFooterView
{
    if (!_tableViewFooterView) {
        _tableViewFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        UIButton *addOneDayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, 120., 34)];
        [addOneDayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addOneDayBtn setTitle:@"收藏想尝的美食" forState:UIControlStateNormal];
//        addOneDayBtn.backgroundColor = APP_THEME_COLOR;
        addOneDayBtn.clipsToBounds = YES;
        [addOneDayBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
        [addOneDayBtn addTarget:self action:@selector(addWantTo:) forControlEvents:UIControlEventTouchUpInside];
        addOneDayBtn.layer.cornerRadius = 2.0;
        addOneDayBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [_tableViewFooterView addSubview:addOneDayBtn];
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, self.tableView.frame.size.width, 1)];
        spaceView.backgroundColor = [UIColor lightGrayColor];
        [_tableViewFooterView addSubview:spaceView];
    }
    return _tableViewFooterView;
}

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    if (!_canEdit) {
        _editBtn.hidden = YES;
    } else {
        _editBtn.hidden = NO;
    }
}

#pragma mark Private Methods

- (void)updateDestinationsHeaderView
{
    NSMutableArray *destinationsArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _tripDetail.destinations) {
        if (poi.zhName) {
            [destinationsArray addObject:poi.zhName];
        }
    }
}

#pragma makr - IBAction Methods

- (IBAction)addWantTo:(id)sender
{
    PoisOfCityTableViewController *restaurantOfCityCtl = [[PoisOfCityTableViewController alloc] init];
    restaurantOfCityCtl.tripDetail = _tripDetail;
    restaurantOfCityCtl.delegate = self;
    restaurantOfCityCtl.poiType = kRestaurantPoi;
    
    restaurantOfCityCtl.shouldEdit = YES;
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:restaurantOfCityCtl];
    [self presentViewController:nctl animated:YES completion:nil];
}

- (void)updateTableView
{
    if (self.tableView.isEditing) {
        self.tableView.tableFooterView = self.tableViewFooterView;
        _editBtn.backgroundColor = APP_THEME_COLOR;
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit_done"] animated:YES];
    } else {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        _editBtn.backgroundColor = UIColorFromRGB(0x797979);
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit"] animated:YES];
    }
    [self.tableView reloadData];
}

- (IBAction)editTrip:(id)sender
{
    if (!self.tableView.isEditing) {
        [self.tableView setEditing:YES animated:YES]; 

        [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
        
    } else {
        [SVProgressHUD show];
        [self.tripDetail saveTrip:^(BOOL isSuccesss) {
            [SVProgressHUD dismiss];
            if (isSuccesss) {
                [self.tableView setEditing:NO animated:YES];
                [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
            } else {
                [SVProgressHUD showSuccessWithStatus:@"保存失败"];
            }
        }];
    }
}

/**
 *  点击我的目的地进入城市详情
 *
 *  @param sender
 */
- (IBAction)viewCityDetail:(UIButton *)sender
{
    CityDestinationPoi *poi = [_tripDetail.destinations objectAtIndex:sender.tag];
    CityDetailTableViewController *cityDetailCtl = [[CityDetailTableViewController alloc] init];
    cityDetailCtl.cityId = poi.cityId;
    [self.rootViewController.navigationController pushViewController:cityDetailCtl animated:YES];
}

#pragma mark - RestaurantsOfCityDelegate

- (void)finishEdit
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tripDetail.restaurantsList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.isEditing) {
        return 0;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.isEditing) {
        return nil;
    }
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:restaurantListReusableIdentifier forIndexPath:indexPath];
    cell.isEditing = self.tableView.isEditing;
    cell.tripPoi = [_tripDetail.restaurantsList objectAtIndex:indexPath.section];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    TripPoi *poi = [_tripDetail.restaurantsList objectAtIndex:sourceIndexPath.section];
    [_tripDetail.restaurantsList removeObjectAtIndex:sourceIndexPath.section];
    [_tripDetail.restaurantsList insertObject:poi atIndex:destinationIndexPath.section];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_tripDetail.restaurantsList removeObjectAtIndex:indexPath.section];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripPoi *tripPoi = [_tripDetail.restaurantsList objectAtIndex:indexPath.section];
    RestaurantDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
    restaurantDetailCtl.restaurantId = tripPoi.poiId;
    [self.rootViewController.navigationController pushViewController:restaurantDetailCtl animated:YES];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _rootViewController = nil;
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 20.0) {
        [_rootViewController showDHView:NO];
    } else {
        [_rootViewController showDHView:YES];
    }
}

@end



