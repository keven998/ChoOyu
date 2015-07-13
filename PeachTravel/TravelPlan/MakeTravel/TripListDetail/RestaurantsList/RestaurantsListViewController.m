//
//  RestaurantsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantsListViewController.h"
#import "CommonPoiListTableViewCell.h"
#import "DestinationsView.h"
#import "CityDestinationPoi.h"
#import "DestinationUnit.h"
#import "CityDetailTableViewController.h"
#import "CommonPoiDetailViewController.h"
#import "PoisOfCityViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "TripPoiListTableViewCell.h"

@interface RestaurantsListViewController () <UITableViewDataSource, UITableViewDelegate, PoisOfCityDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *tableViewFooterView;

@end

@implementation RestaurantsListViewController

static NSString *restaurantListReusableIdentifier = @"tripPoiListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"美食收藏";
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.tableView];
    
    if (_canEdit) {
//        UIButton *toolBar = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49)];
//        toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//        toolBar.backgroundColor = APP_THEME_COLOR;
//        [toolBar setTitle:@"添加收藏" forState:UIControlStateNormal];
//        toolBar.titleLabel.font = [UIFont systemFontOfSize:17.0];
//        [toolBar setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [toolBar addTarget:self action:@selector(addWantTo:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:toolBar];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tableView reloadData];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"Rest willdisappear");
}

#pragma mark - setter & getter

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    [_tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.separatorColor = COLOR_LINE;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:restaurantListReusableIdentifier];
    }
    return _tableView;
}

#pragma makr - IBAction Methods

- (IBAction)addWantTo:(id)sender
{
    [MobClick event:@"event_add_delicacy_schedule"];
    PoisOfCityViewController *restaurantOfCityCtl = [[PoisOfCityViewController alloc] init];
    restaurantOfCityCtl.tripDetail = _tripDetail;
    restaurantOfCityCtl.delegate = self;
    restaurantOfCityCtl.poiType = kRestaurantPoi;
    restaurantOfCityCtl.shouldEdit = YES;
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:restaurantOfCityCtl];
    [self presentViewController:nctl animated:YES completion:nil];

//    [self.navigationController pushViewController:restaurantOfCityCtl animated:YES];
}

- (void)updateTableView
{
    [self.tableView reloadData];
}

- (IBAction)editTrip:(id)sender
{
    if (_shouldEdit) {
        [self.tableView setEditing:YES animated:YES]; 
        [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
        
    } else {
        if (!self.tripDetail.tripIsChange) {
            [self.tableView setEditing:NO animated:YES];
            [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];

            return;
        }
        TZProgressHUD *hud = [[TZProgressHUD alloc] init];
        [hud showHUD];
        
        [self.tripDetail saveTrip:^(BOOL isSuccesss) {
            [hud hideTZHUD];
            if (isSuccesss) {
                [self.tableView setEditing:NO animated:YES];
                [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
            } else {
                [SVProgressHUD showSuccessWithStatus:@"保存失败"];
            }
        }];
    }
}

- (void)jumpMapView:(UIButton *)sender
{
    [MobClick event:@"event_day_map_view"];

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"地图导航"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    for (NSDictionary *dic in platformArray) {
        [sheet addButtonWithTitle:[dic objectForKey:@"platform"]];
    }
    [sheet addButtonWithTitle:@"取消"];
    sheet.tag = sender.tag;
    sheet.cancelButtonIndex = sheet.numberOfButtons-1;
    [sheet showInView:self.view];
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
    [self.navigationController pushViewController:cityDetailCtl animated:YES];
}

- (IBAction)deletePoi:(UIButton *)sender
{
    [MobClick event:@"event_delete_select_item"];
    CGPoint point = [sender convertPoint:CGPointMake(20, 20) toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    [_tripDetail.restaurantsList removeObjectAtIndex:indexPath.row];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.row];
    [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - RestaurantsOfCityDelegate

- (void)finishEdit
{
    [self.tableView reloadData];

}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tripDetail.restaurantsList.count;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:restaurantListReusableIdentifier forIndexPath:indexPath];
    cell.tripPoi = [_tripDetail.restaurantsList objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [MobClick event:@"event_reorder_items"];
    SuperPoi *poi = [_tripDetail.restaurantsList objectAtIndex:sourceIndexPath.row];
    [_tripDetail.restaurantsList removeObjectAtIndex:sourceIndexPath.row];
   
    [_tripDetail.restaurantsList insertObject:poi atIndex:destinationIndexPath.row];
    [self.tableView reloadData];
}

//此举是为了在移动的时候保证顺序。过程有点复杂，慢慢看
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row > 0 && sourceIndexPath.section > proposedDestinationIndexPath.section) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:proposedDestinationIndexPath.section+1];
        return path;
    }
    
    if (sourceIndexPath.section < proposedDestinationIndexPath.section && proposedDestinationIndexPath.row == 0) {
        NSIndexPath *path;
        
        if (proposedDestinationIndexPath.section == sourceIndexPath.section+1) {
            path = [NSIndexPath indexPathForItem:0 inSection:proposedDestinationIndexPath.section-1];

        } else {
            path = [NSIndexPath indexPathForItem:1 inSection:proposedDestinationIndexPath.section-1];

        }
        return path;
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_tripDetail.restaurantsList removeObjectAtIndex:indexPath.row];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *tripPoi = [_tripDetail.restaurantsList objectAtIndex:indexPath.row];

    CommonPoiDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
    restaurantDetailCtl.poiId = tripPoi.poiId;
    restaurantDetailCtl.poiType = kRestaurantPoi;

    [self.navigationController pushViewController:restaurantDetailCtl animated:YES];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    SuperPoi *poi = [_tripDetail.restaurantsList objectAtIndex:actionSheet.tag];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    switch (buttonIndex) {
        case 0:
            switch ([[[platformArray objectAtIndex:0] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    
                default:
                    break;
            }
            break;
            
        case 1:
            switch ([[[platformArray objectAtIndex:1] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            switch ([[[platformArray objectAtIndex:2] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)mapView {
    
}

@end



