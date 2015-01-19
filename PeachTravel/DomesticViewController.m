//
//  DomesticViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "DomesticViewController.h"
#import "TaoziCollectionLayout.h"
#import "DestinationCollectionHeaderView.h"
#import "Destinations.h"
#import "DomesticDestinationCell.h"
#import "MakePlanViewController.h"
#import "TMCache.h"
#import "MJNIndexView.h"

@interface DomesticViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, TaoziLayoutDelegate, MJNIndexViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *domesticCollectionView;
@property (nonatomic, strong) NSDictionary *dataSource;

//索引
@property (nonatomic, strong) MJNIndexView *indexView;

@property (nonatomic, strong) TZProgressHUD *hud;
@end

@implementation DomesticViewController

static NSString *reusableIdentifier = @"cell";
static NSString *reusableHeaderIdentifier = @"domesticHeader";

- (void)viewDidLoad {
    [super viewDidLoad];
    [_domesticCollectionView registerNib:[UINib nibWithNibName:@"DomesticDestinationCell" bundle:nil] forCellWithReuseIdentifier:reusableIdentifier];
    [_domesticCollectionView registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reusableHeaderIdentifier];
    _domesticCollectionView.dataSource = self;
    _domesticCollectionView.delegate = self;
    _domesticCollectionView.showsVerticalScrollIndicator = NO;
    _domesticCollectionView.contentInset = UIEdgeInsetsMake(10, 0, 60, 0);
    
    TaoziCollectionLayout *layout = (TaoziCollectionLayout *)_domesticCollectionView.collectionViewLayout;
    layout.delegate = self;
    layout.showDecorationView = YES;
    layout.margin = 10;
    
    if (_destinations.destinationsSelected.count == 0) {
        [self.makePlanCtl hideDestinationBar];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestinationsSelected:) name:updateDestinationsSelectedNoti object:nil];
    
    CGFloat height = [[self.dataSource objectForKey:@"headerKeys"] count]*35 > (kWindowHeight-64-40) ? (kWindowHeight-64-40) : [[self.dataSource objectForKey:@"headerKeys"] count]*35;
    if (height == 0) {
        height = 100;
    }
    self.indexView = [[MJNIndexView alloc] init];
    [self.indexView setFrame:CGRectMake(0, 0, kWindowWidth-5, height)];
    self.indexView.center = CGPointMake((kWindowWidth-5)/2, (kWindowHeight-64-40)/2);
    [self firstAttributesForMJNIndexView];
    self.indexView.dataSource = self;
    
    [self initData];
}

- (void) initData {
    [[TMCache sharedCache] objectForKey:@"destination_demostic" block:^(TMCache *cache, NSString *key, id object)  {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (object != nil) {
                if ([object isKindOfClass:[NSDictionary class]]) {
                    [_destinations initDomesticCitiesWithJson:[object objectForKey:@"result"]];
                    [self loadDomesticDataFromServerWithLastModified:[object objectForKey:@"lastModified"]];
                    [self updateView];
                } else {
                    [self loadDomesticDataFromServerWithLastModified:@""];
                }
            } else {
                _hud = [[TZProgressHUD alloc] init];
                [_hud showHUD];
                [self loadDomesticDataFromServerWithLastModified:@""];

            }
        });

    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _domesticCollectionView.delegate = nil;
    _domesticCollectionView.dataSource = nil;
}

- (NSDictionary *)dataSource
{
    if (!_dataSource) {
        _dataSource = [self.destinations destinationsGroupByPin];
    }
    return _dataSource;
}

- (void)firstAttributesForMJNIndexView
{
    self.indexView.getSelectedItemsAfterPanGestureIsFinished = YES;
    self.indexView.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    self.indexView.selectedItemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40.0];
    self.indexView.backgroundColor = [UIColor clearColor];
    self.indexView.curtainColor = nil;
    self.indexView.curtainFade = 0.0;
    self.indexView.curtainStays = NO;
    self.indexView.curtainMoves = YES;
    self.indexView.curtainMargins = NO;
    self.indexView.ergonomicHeight = NO;
    self.indexView.upperMargin = 22.0;
    self.indexView.lowerMargin = 22.0;
    self.indexView.rightMargin = 10.0;
    self.indexView.itemsAligment = NSTextAlignmentCenter;
    self.indexView.maxItemDeflection = 30.0;
    self.indexView.rangeOfDeflection = 5;
    self.indexView.fontColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    self.indexView.selectedItemFontColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    self.indexView.darkening = NO;
    self.indexView.fading = YES;
    
}

- (void)reloadData
{
    [self.domesticCollectionView reloadData];
}

- (void)updateView
{
    _dataSource = [_destinations destinationsGroupByPin];
    
    [self.domesticCollectionView reloadData];
    
    CGFloat height = [[self.dataSource objectForKey:@"headerKeys"] count]*35 > (kWindowHeight-64-40) ? (kWindowHeight-64-40) : [[self.dataSource objectForKey:@"headerKeys"] count]*35;
    if (height == 0) {
        height = 100;
    }

    [self.indexView setFrame:CGRectMake(0, 0, kWindowWidth-5, height)];
    self.indexView.center = CGPointMake((kWindowWidth-5)/2, (kWindowHeight-64-40)/2);
    [self.indexView refreshIndexItems];
    [self.indexView removeFromSuperview];
    [self.view addSubview:self.indexView];

}

- (void)tableViewMoveToCorrectPosition:(NSInteger)currentIndex
{
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:currentIndex];
    [_domesticCollectionView scrollToItemAtIndexPath:scrollIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    CGFloat offsetY = [_domesticCollectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:scrollIndexPath].frame.origin.y;
    [_domesticCollectionView setContentOffset:CGPointMake(0, offsetY) animated:YES];
}

/**
 *  获取国内目的地
 */

- (void)loadDomesticDataFromServerWithLastModified:(NSString *)modifiedTime
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"Cache-Control" forHTTPHeaderField:@"private"];
    [manager.requestSerializer setValue:modifiedTime forHTTPHeaderField:@"If-Modified-Since"];
    
    [manager GET:API_GET_DOMESTIC_DESTINATIONS parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_hud) {
            [_hud hideTZHUD];
        }
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id result = [responseObject objectForKey:@"result"];
            [_destinations.domesticCities removeAllObjects];
            [_destinations initDomesticCitiesWithJson:result];
            [self updateView];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableDictionary *dic = [responseObject mutableCopy];
                [dic setObject:[operation.response.allHeaderFields objectForKey:@"Date"] forKey:@"lastModified"];
                [[TMCache sharedCache] setObject:dic forKey:@"destination_demostic"];
            });
        } else {
            if (_hud) {
                if (self.isShowing) {
                    [SVProgressHUD showHint:@"呃～好像没找到网络"];
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_hud) {
            [_hud hideTZHUD];
            if (self.isShowing) {
                [SVProgressHUD showHint:@"呃～好像没找到网络"];
            }
        }
       
    }];
}

#pragma mark - TZScollViewDelegate

- (void)moveToIndex:(NSInteger)index
{
    [self tableViewMoveToCorrectPosition:index];
}

#pragma mark - notification

- (void)updateDestinationsSelected:(NSNotification *)noti
{
    CityDestinationPoi *city = [noti.userInfo objectForKey:@"city"];
    for (int i=0; i<[[self.dataSource objectForKey:@"content"] count]; i++) {
        NSArray *cities = [[self.dataSource objectForKey:@"content"] objectAtIndex:i];
        for (int j=0; j<cities.count; j++) {
            CityDestinationPoi *cityPoi = [cities objectAtIndex:j];
            if ([cityPoi.cityId isEqualToString:city.cityId]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [self.domesticCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
    }
}

#pragma mark -  TaoziLayoutDelegate

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *group = [[self.dataSource objectForKey:@"content"] objectAtIndex:section];
    return [group count];
}

- (CGFloat)tzcollectionLayoutWidth
{
    return self.domesticCollectionView.frame.size.width;
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return [[self.dataSource objectForKey:@"headerKeys"] count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *group = [[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [group objectAtIndex:indexPath.row];
    CGSize size = [city.zhName sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
    return CGSizeMake(size.width + 23.0, size.height + 10);
}

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.domesticCollectionView.frame.size.width, 40);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *group = [[self.dataSource objectForKey:@"content"] objectAtIndex:section];
    return [group count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.dataSource objectForKey:@"headerKeys"] count];
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reusableHeaderIdentifier forIndexPath:indexPath];[[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:indexPath.section];
        headerView.titleLabel.text = [NSString stringWithFormat:@"  %@", [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:indexPath.section]];
        headerView.userInteractionEnabled = NO;
        return headerView;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DomesticDestinationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusableIdentifier forIndexPath:indexPath];
    NSArray *group = [[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [group objectAtIndex:indexPath.row];
    cell.tiltleLabel.text = city.zhName;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([cityPoi.cityId isEqualToString:city.cityId]) {
            cell.layer.borderColor = APP_THEME_COLOR.CGColor;
            cell.tiltleLabel.textColor = APP_THEME_COLOR;
            cell.statusImageView.image = [UIImage imageNamed:@"ic_cell_item_chooesed.png"];
            return  cell;
        }
    }
    cell.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
    cell.tiltleLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    cell.statusImageView.image = [UIImage imageNamed:@"ic_view_add.png"];
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *group = [[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [group objectAtIndex:indexPath.row];
    BOOL find = NO;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([city.cityId isEqualToString:cityPoi.cityId]) {
            NSInteger index = [_destinations.destinationsSelected indexOfObject:cityPoi];
            [_makePlanCtl.destinationToolBar removeUnitAtIndex:index];
            find = YES;
            break;
        }
    }
    if (!find) {
        if (_destinations.destinationsSelected.count == 0) {
            [_makePlanCtl showDestinationBar];
        }
        [_destinations.destinationsSelected addObject:city];
        
        [_makePlanCtl.destinationToolBar addUnit:@"ic_cell_item_unchoose" withName:city.zhName andUnitHeight:26];

        [self.domesticCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

#pragma mark MJMIndexForTableView datasource methods

- (NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView
{
    return [self.dataSource objectForKey:@"headerKeys"];
}

- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    [self.domesticCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}


#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSArray *visiableCells = [self.domesticCollectionView visibleCells];
//    NSInteger firstSection = INT_MAX;
//    
//    for (UICollectionViewCell *cell in visiableCells) {
//        NSIndexPath *indexPath = [self.domesticCollectionView indexPathForCell:cell];
//        (firstSection > indexPath.section) ? (firstSection=indexPath.section) : (firstSection = firstSection);
//    }
//
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
//{
//    NSArray *visiableCells = [self.domesticCollectionView visibleCells];
//    NSInteger firstSection = INT_MAX;
//    
//    for (UICollectionViewCell *CELL in visiableCells) {
//        NSIndexPath *indexPath = [self.domesticCollectionView indexPathForCell:CELL];
//        (firstSection > indexPath.section) ? (firstSection=indexPath.section) : (firstSection = firstSection);
//    }
//    
////    self.tzScrollView.currentIndex = firstSection;
//}

@end




