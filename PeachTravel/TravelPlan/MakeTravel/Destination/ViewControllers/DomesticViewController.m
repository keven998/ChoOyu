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
#import "DomesticCell.h"
#import "MakePlanViewController.h"
#import "TMCache.h"
#import "AreaDestination.h"

@interface DomesticViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *domesticCollectionView;

@property (nonatomic, strong) TZProgressHUD *hud;
@end

@implementation DomesticViewController

static NSString *reusableIdentifier = @"cell";
static NSString *reusableHeaderIdentifier = @"domesticHeader";
static NSString *cacheName = @"destination_demostic_group";

- (void)viewDidLoad {
    [super viewDidLoad];
//    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_domesticCollectionView.collectionViewLayout;
//    layout
//    [_domesticCollectionView registerNib:[UINib nibWithNibName:@"DomesticDestinationCell" bundle:nil] forCellWithReuseIdentifier:reusableIdentifier];
    [_domesticCollectionView registerNib:[UINib nibWithNibName:@"DomesticCell" bundle:nil] forCellWithReuseIdentifier:@"domesticCell"];
    [_domesticCollectionView registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reusableHeaderIdentifier];
    _domesticCollectionView.dataSource = self;
    _domesticCollectionView.delegate = self;
    _domesticCollectionView.showsVerticalScrollIndicator = NO;
    _domesticCollectionView.contentInset = UIEdgeInsetsMake(-5, 0, 35, 0);
    _domesticCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _domesticCollectionView.backgroundColor = APP_PAGE_COLOR;
    
    
    if (_destinations.destinationsSelected.count == 0) {
        [self.makePlanCtl hideDestinationBar];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestinationsSelected:) name:updateDestinationsSelectedNoti object:nil];
    
    [self initData];
}

- (void) initData {
    [[TMCache sharedCache] objectForKey:cacheName block:^(TMCache *cache, NSString *key, id object)  {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (object != nil) {
                if ([object isKindOfClass:[NSDictionary class]]) {
                    [_destinations initDomesticCitiesWithJson:[object objectForKey:@"result"]];
                    [self loadDomesticDataFromServerWithLastModified:[object objectForKey:@"lastModified"]];
                    [self reloadData];
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
    _domesticCollectionView = nil;
}

- (void)reloadData
{
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
    
    NSDictionary *params = @{@"groupBy" : [NSNumber numberWithBool:true]};
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:API_GET_DOMESTIC_DESTINATIONS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@",responseObject);
        
        if (_hud) {
            [_hud hideTZHUD];
        }
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id result = [responseObject objectForKey:@"result"];
            [_destinations.domesticCities removeAllObjects];
            [_destinations initDomesticCitiesWithJson:result];
            [self reloadData];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableDictionary *dic = [responseObject mutableCopy];
                if ([operation.response.allHeaderFields objectForKey:@"Date"]) {
                    [dic setObject:[operation.response.allHeaderFields objectForKey:@"Date"]  forKey:@"lastModified"];
                    [[TMCache sharedCache] setObject:dic forKey:cacheName];
                }
               
            });
        } else {
            if (_hud) {
                if (self.isShowing) {
                    [SVProgressHUD showHint:@"呃～好像没找到网络"];
                }
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_hud) {
            [_hud hideTZHUD];
            if (self.isShowing) {
                [SVProgressHUD showHint:@"呃～好像没找到网络"];
            }
        }
       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
    for (int i=0; i<self.destinations.domesticCities.count; i++) {
        AreaDestination *area = [self.destinations.domesticCities objectAtIndex:i];
        for (int j=0; j<area.cities.count; j++) {
            CityDestinationPoi *cityPoi = [area.cities objectAtIndex:j];
            if ([cityPoi.cityId isEqualToString:city.cityId]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [self.domesticCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
    }
}

#pragma mark -  TaoziLayoutDelegate
/*
- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:section];
    return [area.cities count];
}

- (CGFloat)tzcollectionLayoutWidth
{
    return self.domesticCollectionView.frame.size.width;
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return self.destinations.domesticCities.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(SCREEN_WIDTH/4, SCREEN_WIDTH/4); //left-right margin + status image size
}

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.domesticCollectionView.frame.size.width, 38);
}
*/
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return CGSizeMake(SCREEN_WIDTH/3, SCREEN_WIDTH/3);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    return CGSizeMake(self.domesticCollectionView.frame.size.width, 38);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
{
    return 0;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:section];
    return [area.cities count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.destinations.domesticCities.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reusableHeaderIdentifier forIndexPath:indexPath];
        AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
        headerView.titleLabel.text = area.zhName;
        return headerView;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DomesticCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"domesticCell" forIndexPath:indexPath];
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [area.cities objectAtIndex:indexPath.row];
    cell.tiltleLabel.text = city.zhName;
    
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([cityPoi.cityId isEqualToString:city.cityId]) {
            cell.tiltleLabel.textColor = [UIColor whiteColor];
            cell.status.image = [UIImage imageNamed:@"ic_cell_item_chooesed.png"];
            cell.backgroundColor = APP_THEME_COLOR;
            return  cell;
        }
    }
    cell.tiltleLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    cell.status.image = [UIImage imageNamed:@"ic_cell_item_unchoose.png"];
    cell.backgroundColor = [UIColor whiteColor];
    
#warning 这里的city模型需要增加image属性来给cell的背景图片赋值
    // 设置cell的背景图片
//    NSURL * url = [NSURL URLWithString:city.enName];
//    [cell.backGroundImage sd_setImageWithURL:url];
    
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"event_select_city"];
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [area.cities objectAtIndex:indexPath.row];
    BOOL find = NO;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([city.cityId isEqualToString:cityPoi.cityId]) {
            NSInteger index = [_destinations.destinationsSelected indexOfObject:cityPoi];
            [_destinations.destinationsSelected removeObjectAtIndex:index];
            NSIndexPath *lnp = [NSIndexPath indexPathForItem:index inSection:0];
            [_makePlanCtl.selectPanel performBatchUpdates:^{
                [_makePlanCtl.selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
            } completion:^(BOOL finished) {
                if (_destinations.destinationsSelected.count == 0) {
                    [_makePlanCtl hideDestinationBar];
                }
            }];
            find = YES;
            break;
        }
    }
    if (!find) {
        if (_destinations.destinationsSelected.count == 0) {
            [_makePlanCtl showDestinationBar];
        }
        [_destinations.destinationsSelected addObject:city];
        NSIndexPath *lnp = [NSIndexPath indexPathForItem:(_destinations.destinationsSelected.count-1) inSection:0];
        [_makePlanCtl.selectPanel performBatchUpdates:^{
            [_makePlanCtl.selectPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
        } completion:^(BOOL finished) {
            if (finished) {
                [_makePlanCtl.selectPanel scrollToItemAtIndexPath:lnp
                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
        }];
    }
    [self.domesticCollectionView reloadItemsAtIndexPaths:@[indexPath]];
}

@end




