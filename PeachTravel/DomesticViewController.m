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
#import "TZScrollView.h"
#import "MakePlanViewController.h"
#import "TMCache.h"

@interface DomesticViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, TaoziLayoutDelegate, TZScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *domesticCollectionView;
@property (nonatomic, strong) TZScrollView *tzScrollView;
@property (nonatomic, strong) NSDictionary *dataSource;

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
    
    TaoziCollectionLayout *layout = (TaoziCollectionLayout *)_domesticCollectionView.collectionViewLayout;
    layout.delegate = self;
    layout.showDecorationView = YES;
    layout.margin = 10;
    
    if (_destinations.destinationsSelected.count == 0) {
        [self.makePlanCtl hideDestinationBar];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestinationsSelected:) name:updateDestinationsSelectedNoti object:nil];
    
    [self initData];
}

- (void) initData {
    [[TMCache sharedCache] objectForKey:@"destination_demostic" block:^(TMCache *cache, NSString *key, id object)  {
        if (object != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_destinations initDomesticCitiesWithJson:object];
                [self updateView];
            });
        } else {
            [self loadDomesticDataFromServer];
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tzScrollView.delegate = nil;
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

- (TZScrollView *)tzScrollView
{
    if (!_tzScrollView) {
        _tzScrollView = [[TZScrollView alloc] initWithFrame:CGRectMake(0, 10.0, kWindowWidth, 52.0)];
        _tzScrollView.itemWidth = 22;
        _tzScrollView.itemHeight = 22;
        _tzScrollView.itemBackgroundColor = UIColorFromRGB(0xd2d2d2);
        _tzScrollView.backgroundColor = [UIColor whiteColor];
        _tzScrollView.layer.shadowRadius = 0.5;
        _tzScrollView.layer.shadowColor = APP_DIVIDER_COLOR.CGColor;
        _tzScrollView.layer.shadowOffset = CGSizeMake(0.0, 0.5);
        _tzScrollView.layer.shadowOpacity = 1.0;
        _tzScrollView.delegate = self;
        _tzScrollView.titles = [self.dataSource objectForKey:@"headerKeys"];
    }
    return _tzScrollView;
}

- (void)reloadData
{
    [self.domesticCollectionView reloadData];
}

- (void)updateView
{
    _dataSource = [_destinations destinationsGroupByPin];
    [self.view addSubview:self.tzScrollView];
    [self.domesticCollectionView reloadData];
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

- (void)loadDomesticDataFromServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //获取活内目的地的话 abroad 为0
    [params setObject:[NSNumber numberWithInt:0] forKey:@"abroad"];
    [SVProgressHUD show];
    
    [manager GET:API_GET_DESTINATIONS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id result = [responseObject objectForKey:@"result"];
            [_destinations initDomesticCitiesWithJson:result];
            [self updateView];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[TMCache sharedCache] setObject:result forKey:@"destination_demostic"];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *visiableCells = [self.domesticCollectionView visibleCells];
    NSInteger firstSection = INT_MAX;
    
    for (UICollectionViewCell *cell in visiableCells) {
        NSIndexPath *indexPath = [self.domesticCollectionView indexPathForCell:cell];
        (firstSection > indexPath.section) ? (firstSection=indexPath.section) : (firstSection = firstSection);
    }
    self.tzScrollView.currentIndex = firstSection;

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    NSArray *visiableCells = [self.domesticCollectionView visibleCells];
    NSInteger firstSection = INT_MAX;
    
    for (UICollectionViewCell *CELL in visiableCells) {
        NSIndexPath *indexPath = [self.domesticCollectionView indexPathForCell:CELL];
        (firstSection > indexPath.section) ? (firstSection=indexPath.section) : (firstSection = firstSection);
    }
    
    self.tzScrollView.currentIndex = firstSection;
}

@end




