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

@interface DomesticViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, TaoziLayoutDelegate, DestinationToolBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *domesticCollectionView;
@property (nonatomic, strong) TZScrollView *tzScrollView;
@property (nonatomic, strong) NSDictionary *dataSource;

@end

@implementation DomesticViewController

static NSString *reusableIdentifier = @"cell";
static NSString *reusableHeaderIdentifier = @"domesticHeader";

- (void)viewDidLoad {
    [super viewDidLoad];
    _makePlanCtl.destinationToolBar.delegate = self;
    [_domesticCollectionView registerNib:[UINib nibWithNibName:@"DomesticDestinationCell" bundle:nil] forCellWithReuseIdentifier:reusableIdentifier];
    [_domesticCollectionView registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reusableHeaderIdentifier];
    _domesticCollectionView.dataSource = self;
    _domesticCollectionView.delegate = self;
    [(TaoziCollectionLayout *)_domesticCollectionView.collectionViewLayout setDelegate:self];
    [self loadDomesticDataFromServer];
    if (_destinations.destinationsSelected.count == 0) {
        [self.makePlanCtl.destinationToolBar setHidden:YES withAnimation:YES];
    }
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
        
        _tzScrollView = [[TZScrollView alloc] initWithFrame:CGRectMake(0, 10, kWindowWidth, 40)];
        _tzScrollView.scrollView.delegate = self;
        _tzScrollView.itemWidth = 80;
        _tzScrollView.itemHeight = 40;
        _tzScrollView.itemBackgroundColor = [UIColor greenColor];
        _tzScrollView.backgroundColor = [UIColor greenColor];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i<[[self.dataSource objectForKey:@"headerKeys"] count]; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
            NSString *s = [[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:i];
            [button setTitle:s forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor greenColor]];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            button.tag = i;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [array addObject:button];
        }        _tzScrollView.viewsOnScrollView = array;
        for (UIButton *tempBtn in _tzScrollView.viewsOnScrollView) {
            [tempBtn addTarget:self action:@selector(choseCurrent:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _tzScrollView;
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

- (void)loadDomesticDataFromServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [SVProgressHUD show];
    
    //获取首页数据
    [manager GET:API_GET_RECOMMEND parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [_destinations initDomesticCitiesWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - IBAction Methods

- (IBAction)choseCurrent:(UIButton *)sender
{
    _tzScrollView.currentIndex = sender.tag;
    [self tableViewMoveToCorrectPosition:sender.tag];
}

#pragma mark - DestinationToolBarDelegate

- (void)removeUintCell:(NSInteger)index
{
    CityDestinationPoi *city = [_destinations.destinationsSelected objectAtIndex:index];
    [_destinations.destinationsSelected removeObjectAtIndex:index];
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
    if (self.destinations.destinationsSelected.count == 0) {
        [self.makePlanCtl.destinationToolBar setHidden:YES withAnimation:YES];
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
    return CGSizeMake(size.width+30, size.height+10);
}

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.domesticCollectionView.frame.size.width, 40);
}

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
    DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reusableHeaderIdentifier forIndexPath:indexPath];
    [headerView.titleBtn setTitle:[[self.dataSource objectForKey:@"headerKeys"] objectAtIndex:indexPath.section] forState:UIControlStateNormal];
    return headerView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DomesticDestinationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusableIdentifier forIndexPath:indexPath];
    NSArray *group = [[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [group objectAtIndex:indexPath.row];
    cell.tiltleLabel.text = city.zhName;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([cityPoi.cityId isEqualToString:city.cityId]) {
            cell.layer.borderColor = UIColorFromRGB(0xee528c).CGColor;
            return  cell;
        }
    }
    cell.layer.borderColor = UIColorFromRGB(0xf5f5f5).CGColor;
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *group = [[self.dataSource objectForKey:@"content"] objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [group objectAtIndex:indexPath.row];
    if (_destinations.destinationsSelected.count == 0) {
        [self.makePlanCtl.destinationToolBar setHidden:NO withAnimation:YES];
    }
    [_destinations.destinationsSelected addObject:city];
    [_makePlanCtl.destinationToolBar addNewUnitWithName:city.zhName];
    [self.domesticCollectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.tzScrollView.scrollView) {
        CGPoint currentOffset = scrollView.contentOffset;
        
        NSLog(@"offset: %@", NSStringFromCGPoint(currentOffset));
        
        int currentIndex = (int)(currentOffset.x)/80;
        if (currentIndex > ([[self.dataSource objectForKey:@"headerKeys"] count] -1)) {
            currentIndex = ([[self.dataSource objectForKey:@"headerKeys"] count] -1);
        }
        if (currentIndex < 0) {
            currentIndex = 0;
        }
        _tzScrollView.currentIndex = currentIndex;
        [self tableViewMoveToCorrectPosition:currentIndex];
        
    } else if (scrollView == self.domesticCollectionView) {
            NSArray *visiableCells = [self.domesticCollectionView visibleCells];
            
            NSInteger firstSection = INT_MAX;
            
            for (UICollectionViewCell *cell in visiableCells) {
                NSIndexPath *indexPath = [self.domesticCollectionView indexPathForCell:cell];
                (firstSection > indexPath.section) ? (firstSection=indexPath.section) : (firstSection = firstSection);
            }
            self.tzScrollView.currentIndex = firstSection;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if (scrollView == self.tzScrollView.scrollView) {
        CGPoint currentOffset = scrollView.contentOffset;
        int currentIndex = (int)(currentOffset.x)/80;
        if (currentIndex > ([[self.dataSource objectForKey:@"headerKeys"] count] -1)) {
            currentIndex = ([[self.dataSource objectForKey:@"headerKeys"] count] -1);
        }

        if (currentIndex < 0) {
            currentIndex = 0;
        }
        _tzScrollView.currentIndex = currentIndex;
        [self tableViewMoveToCorrectPosition:currentIndex];
        
    } else if (scrollView == self.domesticCollectionView) {
        NSArray *visiableCells = [self.domesticCollectionView visibleCells];
        
        NSInteger firstSection = INT_MAX;
        
        for (UICollectionViewCell *CELL in visiableCells) {
            NSIndexPath *indexPath = [self.domesticCollectionView indexPathForCell:CELL];
            (firstSection > indexPath.section) ? (firstSection=indexPath.section) : (firstSection = firstSection);
        }
        
        self.tzScrollView.currentIndex = firstSection;
    }
}

@end




