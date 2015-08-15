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

@property (nonatomic, strong)NSMutableDictionary * showDic;

@property (nonatomic, strong)NSMutableArray * shoppListArray;

@property (nonatomic, strong)NSMutableArray * dataSource;

@end

@implementation RestaurantsListViewController

static NSString *restaurantListReusableIdentifier = @"tripPoiListCell";

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"想去的美食";
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.tableView];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(18, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"page_plan_favorite_pois_lists_type_restaurant"];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"page_plan_favorite_pois_lists_type_restaurant"];
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
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:restaurantListReusableIdentifier];
    }
    return _tableView;
}

#pragma makr - IBAction Methods

- (IBAction)addWantTo:(NSInteger)page
{
    PoisOfCityViewController *restaurantOfCityCtl = [[PoisOfCityViewController alloc] init];
    restaurantOfCityCtl.tripDetail = _tripDetail;
    restaurantOfCityCtl.page = page;
    restaurantOfCityCtl.delegate = self;
    restaurantOfCityCtl.poiType = kRestaurantPoi;
    restaurantOfCityCtl.shouldEdit = YES;
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:restaurantOfCityCtl];
    [self presentViewController:nctl animated:YES completion:nil];
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

#pragma mark - 设置分组的头部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 1.创建一个容器对象Button
    UIButton * containBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [containBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [containBtn setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateHighlighted];
    [containBtn addTarget:self action:@selector(mergeTable:) forControlEvents:UIControlEventTouchUpInside];
    containBtn.tag = section;
    
    // 2.创建Button上面的视图
    NSArray * dataSource = [self revertShoppingListToGroup:_tripDetail.restaurantsList];
    NSArray * shoppingArray = dataSource[section];
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:12.0f];
    label.frame = CGRectMake(12, 16, 100, 12);
    [label setTextColor:COLOR_TEXT_II];
    CityDestinationPoi * poi = self.tripDetail.destinations[section];
    NSString * title = [NSString stringWithFormat:@"%@美食（%ld）",poi.zhName,shoppingArray.count];
    label.text = title;
    [containBtn addSubview:label];
    
    if (_canEdit) {
        // 3.创建收藏Button
        UIButton * collection = [UIButton buttonWithType:UIButtonTypeCustom];
        collection.tag = section;
        CGFloat collectionW = 52;
        collection.frame = CGRectMake(kWindowWidth - 10 - collectionW, 8.5, collectionW, 26);
        [collection setTitle:@"＋想去" forState:UIControlStateNormal];
        collection.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [collection setTitleColor:COLOR_TEXT_III forState:UIControlStateNormal];
        [collection setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
        collection.layer.cornerRadius = 4.0;
        collection.layer.borderWidth = 1.0;
        collection.titleEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 0);
        collection.layer.borderColor = COLOR_LINE.CGColor;
        [collection addTarget:self action:@selector(collectionShop:) forControlEvents:UIControlEventTouchUpInside];
        [containBtn addSubview:collection];
    }
    
    // 4.创建头部的横条
    UIButton * banner = [UIButton buttonWithType:UIButtonTypeCustom];
    banner.backgroundColor = APP_THEME_COLOR;
    banner.frame = CGRectMake(0, 0, kWindowWidth, 1);
    [containBtn addSubview:banner];
    
    return containBtn;
}

// 监听收藏按钮的点击事件
- (void)collectionShop:(UIButton *)collection
{
    [MobClick event:@"button_item_add_favorite"];
    [self addWantTo:collection.tag];
}

// 合并表格
- (void)mergeTable:(UIButton *)contain
{
    NSInteger didSection = contain.tag;
    
    if (!_showDic) {
        _showDic = [[NSMutableDictionary alloc]init];
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld",didSection];
    if (![_showDic objectForKey:key]) {
        [_showDic setObject:@"1" forKey:key];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:didSection] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [_showDic removeObjectForKey:key];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:didSection] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSArray * dataSource = [self revertShoppingListToGroup:_tripDetail.restaurantsList];
        NSArray * shoppingArray = dataSource[didSection];
        if (shoppingArray.count > 0) {
            [self performSelector:@selector(scrollToVisiable:) withObject:[NSNumber numberWithLong:didSection] afterDelay:0.35];
        }
    }
}

- (void)scrollToVisiable:(NSNumber *)section {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[section intValue]]
                          atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

// 处理shoppingList数组
- (NSArray *)revertShoppingListToGroup:(NSArray *)shoppingList
{
    // 1.创建一个分组数组,里面存放了多少组数据
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i < _tripDetail.destinations.count; i++) {
        
        NSMutableArray * array = [NSMutableArray array];
        [dataSource addObject:array];
    }
    
    // 2.遍历数组
    for (RestaurantPoi * poi in shoppingList) {
        CityDestinationPoi * cityPoi = poi.locality;
        int i = 0;
        for (CityDestinationPoi * destpoi in _tripDetail.destinations)
        {
            if ([cityPoi.cityId isEqualToString:destpoi.cityId]) {
                NSMutableArray *array = dataSource[i];
                [array addObject:poi];
                break;
            }
            i++;
        }
    }
    
    return dataSource;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![_showDic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.section]]) {
        return 72;
    }
    return 0;
}

#pragma mark - UITableViewDataSource & Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 43;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 19.5;
}

// 1.返回有多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    NSArray * dataSource = [self revertShoppingListToGroup:_tripDetail.restaurantsList];
    
    return dataSource.count;
}

// 2.返回每组的cell行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * dataSource = [self revertShoppingListToGroup:_tripDetail.restaurantsList];
    NSArray * shoppingArray = dataSource[section];
    return shoppingArray.count;
}


// 3.初始化每组的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:restaurantListReusableIdentifier forIndexPath:indexPath];
    cell.clipsToBounds = YES;
    
    NSArray * dataSource = [self revertShoppingListToGroup:_tripDetail.restaurantsList];
    NSArray * shoppingArray = dataSource[indexPath.section];
    cell.tripPoi = shoppingArray[indexPath.row];
    
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



