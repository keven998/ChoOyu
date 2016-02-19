//
//  ShoppingListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ShoppingListViewController.h"
#import "CommonPoiListTableViewCell.h"
#import "DestinationsView.h"
#import "CityDestinationPoi.h"
#import "DestinationUnit.h"
#import "CityDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "PoisOfCityViewController.h"
#import "ShoppingDetailViewController.h"
#import "TripPoiListTableViewCell.h"
@interface ShoppingListViewController () <UITableViewDataSource, UITableViewDelegate, PoisOfCityDelegate, UIActionSheetDelegate>

// 表格cell是否关闭
@property (nonatomic, assign) BOOL isClosed;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *tableViewFooterView;
@property (nonatomic, strong) NSMutableDictionary *showDic;
@property (nonatomic, strong) NSMutableArray *shoppListArray;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ShoppingListViewController

static NSString *shoppingListReusableIdentifier = @"tripPoiListCell";

// 懒加载shoppingList
- (NSMutableArray *)shoppListArray
{
    if (_shoppListArray == nil) {
        _shoppListArray = [NSMutableArray array];
    }
    return _shoppListArray;
}

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"收集的购物";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    self.isClosed = YES;
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"page_plan_favorite_pois_lists_type_shop"];
    [super viewWillAppear:animated];
      
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"page_plan_favorite_pois_lists_type_shop"];
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
}


#pragma mark - setter & getter

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    _dataSource = [self revertShoppingListToGroup:_tripDetail.shoppingList];
    [_tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.separatorColor = COLOR_LINE;
        [_tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:shoppingListReusableIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    }
    return _tableView;
}

#pragma makr - IBAction Methods

- (void)addWantTo:(NSInteger)page
{
    PoisOfCityViewController *shoppingOfCityCtl = [[PoisOfCityViewController alloc] init];
    NSLog(@"%@",_tripDetail);
    shoppingOfCityCtl.tripDetail = _tripDetail;
    shoppingOfCityCtl.selectedArray = _dataSource[page];
    shoppingOfCityCtl.delegate = self;
    shoppingOfCityCtl.poiType = kShoppingPoi;
    shoppingOfCityCtl.shouldEdit = YES;
    shoppingOfCityCtl.page = page;
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:shoppingOfCityCtl];
    [self presentViewController:nctl animated:YES completion:nil];
}

- (void)updateTableView
{
    self.dataSource = [self revertShoppingListToGroup:_tripDetail.shoppingList];
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
    CityDetailViewController *cityDetailCtl = [[CityDetailViewController alloc] init];
    cityDetailCtl.cityId = poi.cityId;
    cityDetailCtl.cityName = poi.zhName;
    [self.rootViewController.navigationController pushViewController:cityDetailCtl animated:YES];
}

// 删除景点
- (IBAction)deletePoi:(UIButton *)sender
{
    CGPoint point = [sender convertPoint:CGPointMake(20, 20) toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    [_tripDetail.shoppingList removeObjectAtIndex:indexPath.row];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.row];
    [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - ShoppingOfCityDelegate

- (void)finishEdit
{
    [self updateTableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]]) {
        return 72;
    }
    return 0;
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
    NSArray * shoppingArray = _dataSource[section];
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:12.0f];
    label.frame = CGRectMake(12, 16, 100, 12);
    [label setTextColor:COLOR_TEXT_II];
    CityDestinationPoi * poi = self.tripDetail.destinations[section];
    NSString * title = [NSString stringWithFormat:@"%@购物（%ld）",poi.zhName,shoppingArray.count];
    label.text = title;
    [containBtn addSubview:label];
    
    if (_canEdit) {
        // 3.创建收藏Button
        UIButton * collection = [UIButton buttonWithType:UIButtonTypeCustom];
        collection.tag = section;
        CGFloat collectionW = 52;
        collection.frame = CGRectMake(kWindowWidth - 10 - collectionW, 8.5, collectionW, 26);
        [collection setTitle:@"＋收集" forState:UIControlStateNormal];
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
        NSArray * shoppingArray = _dataSource[didSection];
        if (shoppingArray.count > 0) {
            [self performSelector:@selector(scrollToVisiable:) withObject:[NSNumber numberWithLong:didSection] afterDelay:0.35];
        }
    }
}


- (void)scrollToVisiable:(NSNumber *)section {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[section intValue]]
                          atScrollPosition:UITableViewScrollPositionNone animated:YES];
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
    return _dataSource.count;
}

// 2.返回每组的cell行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * shoppingArray = _dataSource[section];
    return self.isClosed ? shoppingArray.count : 0;
}

// 3.初始化每组的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:shoppingListReusableIdentifier forIndexPath:indexPath];
    cell.clipsToBounds = YES;
    NSArray * shoppingArray = _dataSource[indexPath.section];
    cell.tripPoi = shoppingArray[indexPath.row];
    return cell;
}

// 处理shoppingList数组
- (NSMutableArray *)revertShoppingListToGroup:(NSArray *)shoppingList
{
    // 1.创建一个分组数组,里面存放了多少组数据
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i < _tripDetail.destinations.count; i++) {
        NSMutableArray * array = [NSMutableArray array];
        [dataSource addObject:array];
    }
    
    // 2.遍历数组
    for (ShoppingPoi * poi in shoppingList) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *tripPoi = [_tripDetail.shoppingList objectAtIndex:indexPath.row];
    CommonPoiDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
    shoppingDetailCtl.poiId = tripPoi.poiId;
    shoppingDetailCtl.poiType = kShoppingPoi;
    [self.navigationController pushViewController:shoppingDetailCtl animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    SuperPoi *poi = [_tripDetail.shoppingList objectAtIndex:actionSheet.tag];
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



