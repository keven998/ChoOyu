//
//  SearchDestinationRecommendViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "SearchDestinationRecommendViewController.h"
#import "SearchDestinationHistoryCollectionReusableView.h"
#import "DestinationSearchHistoryCell.h"
#import "TaoziCollectionLayout.h"

@interface SearchDestinationRecommendViewController () <UICollectionViewDataSource, UICollectionViewDelegate, TaoziLayoutDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray * collectionArray;
@property (nonatomic, strong) UIColor *itemColor;
@property (nonatomic, copy) NSString *searchHistoryImage;

@end

@implementation SearchDestinationRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self loadHotSearchWithPoiType:0];
    NSArray * recentResult = [[TMCache sharedCache] objectForKey:[self destinationCacheKey]];
    if (recentResult) {
        self.collectionArray[0] = recentResult;
    }
    [self.collectionView reloadData];
    if (_poiType == kRestaurantPoi) {
        _itemColor = UIColorFromRGB(0xFD8627);
        _searchHistoryImage = @"icon_restaurant_search.png";

        
    } else if (_poiType == kShoppingPoi) {
        _itemColor = UIColorFromRGB(0xF64760);
        _searchHistoryImage = @"icon_shopping_search.png";

    } else if (_poiType == kSpotPoi) {
        _itemColor = UIColorFromRGB(0x57C0FF);
        _searchHistoryImage = @"icon_spot_search.png";

    } else if (_poiType == kTravelNotePoi) {
        _itemColor = APP_THEME_COLOR;
        _searchHistoryImage = @"icon_travelnote_search.png";
        
    } else {
        _itemColor = APP_THEME_COLOR;
        _searchHistoryImage = @"icon_common_search.png";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)collectionArray
{
    if (_collectionArray == nil) {
        _collectionArray = [[NSMutableArray alloc] init];
        NSMutableArray *historyArray = [[NSMutableArray alloc] init];
        [_collectionArray addObject:historyArray];
        NSMutableArray *recommendArray = [[NSMutableArray alloc] init];
        [_collectionArray addObject:recommendArray];
    }
    return _collectionArray;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
        layout.delegate = self;
        layout.showDecorationView = NO;
        layout.spacePerItem = 12;
        layout.spacePerLine = 15;
        layout.margin = 10;

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerNib:[UINib nibWithNibName:@"DestinationSearchHistoryCell" bundle:nil] forCellWithReuseIdentifier:@"searchHistoryCell"];
        [_collectionView registerNib:[UINib nibWithNibName:@"SearchDestinationHistoryCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"searchDestinationHeader"];
    }
    return _collectionView;
}

- (void)clearSearchHistory
{
    [[TMCache sharedCache] removeObjectForKey:[self destinationCacheKey]];
    [_collectionArray[0] removeAllObjects];
    [_collectionView reloadData];
}

- (NSString *)destinationCacheKey
{
    NSString *commomKey = kSearchDestinationCacheKey;
    if (_poiType != 0) {
        return [NSString stringWithFormat:@"%@_%ld", commomKey, _poiType];
    }
    return commomKey;
}

- (void)addSearchHistoryText:(NSString *)searchText
{
    // 将搜索结果存入到数据库中
    NSArray * recentSearch = [[TMCache sharedCache] objectForKey:[self destinationCacheKey]];
    NSMutableArray * mutableArray;
    if (recentSearch) {
        mutableArray = [recentSearch mutableCopy];
    } else {
        mutableArray = [[NSMutableArray alloc] init];
    }
    for (NSString *str in mutableArray) {
        if ([str isEqualToString:searchText]) {
            [mutableArray removeObject:str];
            break;
        }
    }
    if (mutableArray.count >= 10) {
        [mutableArray removeLastObject];
    }
    [mutableArray insertObject:searchText atIndex:0];
    [[TMCache sharedCache] setObject:mutableArray forKey:[self destinationCacheKey]];
    self.collectionArray[0] = mutableArray;
    [self.collectionView reloadData];
}

#pragma mark - 加载网络数据
- (void)loadHotSearchWithPoiType:(TZPoiType)poiType
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *params;
    if (_poiType == kRestaurantPoi) {
        params = @{@"scope": @"restaurant"};
        
    } else if (_poiType == kShoppingPoi) {
        params = @{@"scope": @"shopping"};
        
    } else if (_poiType == kSpotPoi) {
        params = @{@"scope": @"viewspot"};
        
    } else if (_poiType == kTravelNotePoi) {
        params = @{@"scope": @"travelNote"};
    }
    
    [manager GET:API_GET_HOT_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray * searchNameArray = [NSMutableArray array];
        NSArray *resultArray = responseObject[@"result"];
        
        for (NSDictionary * resultDict in resultArray) {
            NSString * searchName = resultDict[@"zhName"];
            [searchNameArray addObject:searchName];
        }
        
        [self setupCollectionDataSourceWithHotSearchResult:searchNameArray];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error);
    }];
}

- (void)setupCollectionDataSourceWithHotSearchResult:(NSArray *)hotSearchResult
{
    if (hotSearchResult) {
        self.collectionArray[1] = hotSearchResult;
    }
    [self.collectionView reloadData];
}


#pragma mark - 实现UICollectionView的数据源以及代理方法

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _collectionArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[_collectionArray objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DestinationSearchHistoryCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchHistoryCell" forIndexPath:indexPath];
    NSArray *array = [_collectionArray objectAtIndex:indexPath.section];
    cell.titleLabel.text = array[indexPath.row];
    cell.itemColor = _itemColor;
    return cell;
}

// collection的头部
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SearchDestinationHistoryCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"searchDestinationHeader" forIndexPath:indexPath];
        if (indexPath.section == 0 && [[self.collectionArray objectAtIndex:0] count]) {
            headerView.titleLabel.text = @"历史搜索";
            headerView.actionButton.hidden = NO;
            [headerView.actionButton setTitle:@"清除" forState:UIControlStateNormal];
            [headerView.actionButton addTarget:self action:@selector(clearSearchHistory) forControlEvents:UIControlEventTouchUpInside];
            headerView.dotImageView.image = [UIImage imageNamed:_searchHistoryImage];
            
        } else if (indexPath.section == 1 && [[self.collectionArray objectAtIndex:1] count]) {
            headerView.titleLabel.text = @"热门搜索";
            headerView.dotImageView.image = [UIImage imageNamed:@"icon_hot_search.png"];
            headerView.actionButton.hidden = YES;
        }
        return headerView;
    }
    
    return nil;
}

// 选中某一个item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [self.collectionArray objectAtIndex:indexPath.section];
    NSString *text = array[indexPath.row];
    [self addSearchHistoryText:text];
    if ([self.delegate respondsToSelector:@selector(didSelectItemWithSearchText:)]) {
        [self.delegate didSelectItemWithSearchText:text];
    }
}

#pragma mark - TaoziLayoutDelegate

- (CGSize)tzCollectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [_collectionArray objectAtIndex:indexPath.section];
    NSString *title = [array objectAtIndex:indexPath.row];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]}];
    return CGSizeMake(size.width+20, 30);
}

- (CGSize)tzCollectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && [[self.collectionArray objectAtIndex:0] count]) {
        return CGSizeMake(kWindowWidth, 50);
    } else if (indexPath.section == 1 && [[self.collectionArray objectAtIndex:1] count]) {
        return CGSizeMake(kWindowWidth, 50);
    }
    return CGSizeZero;
}

- (NSInteger)tzNumberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return _collectionArray.count;
}

- (NSInteger)tzCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[_collectionArray objectAtIndex:section] count];
}

- (CGFloat)tzCollectionLayoutWidth
{
    return self.view.bounds.size.width-20;
}

@end
