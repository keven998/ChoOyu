//
//  FootPrintViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "FootPrintViewController.h"
#import "TaoziCollectionLayout.h"
#import "FootprintMapViewController.h"
#import "ScreenningViewCell.h"
#import "DestinationCollectionHeaderView.h"
#import "SwipeView.h"
#import "AreaDestination.h"

@interface FootPrintViewController ()<TaoziLayoutDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSMutableArray *_dataArray;
}
@property (nonatomic, strong) FootprintMapViewController *footprintMapCtl;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) SwipeView *swipeView;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation FootPrintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self downloadData:@"" url:API_GET_DOMESTIC_DESTINATIONS];
    _footprintMapCtl = [[FootprintMapViewController alloc] init];
    [_footprintMapCtl.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    [self addChildViewController:_footprintMapCtl];
    [self.view addSubview:_footprintMapCtl.view];
    [_footprintMapCtl didMoveToParentViewController:self];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(3, 15, 44, 44)];
    [backBtn setImage:[UIImage imageNamed:@"ic_navigation_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 50, 50)];
//    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [btn setTitle:@"添加" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(addFootprint:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];

    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:@[@"国内",@"国外"]];
    segControl.tintColor = APP_THEME_COLOR;
    segControl.frame = CGRectMake(0, 0, 136, 28);
    segControl.center = CGPointMake(SCREEN_WIDTH/2, 220);
    segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    segControl.selectedSegmentIndex = 0;
    [self.view addSubview:segControl];
    [segControl addTarget:self action:@selector(selectedPage:) forControlEvents:UIControlEventValueChanged];
    
    [self createCollectionView];

}
-(void)selectedPage:(UISegmentedControl *)segment {
    if (segment.selectedSegmentIndex == 0) {
        [self downloadData:@"" url:API_GET_DOMESTIC_DESTINATIONS];
    }else{
        [self downloadData:@"" url:API_GET_FOREIGN_DESTINATIONS];
    }
}








-(void)createCollectionView
{
    TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
    layout.delegate = self;
    
    _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 234, SCREEN_WIDTH, SCREEN_HEIGHT-240) collectionViewLayout:layout];
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    
    
    [_collectionView registerNib:[UINib nibWithNibName:@"ScreenningViewCell" bundle:nil]  forCellWithReuseIdentifier:@"cell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"domesticHeader"];
    [self.view addSubview:_collectionView];
    layout.showDecorationView = YES;
    layout.margin = 10;
    layout.spacePerItem = 10;
    layout.spacePerLine = 10;
    
}
#pragma mark -  TaoziLayoutDelegate

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:section];
    return [area.cities count];
}

- (CGFloat)tzcollectionLayoutWidth
{
    return _collectionView.frame.size.width;
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return self.destinations.domesticCities.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [area.cities objectAtIndex:indexPath.row];
    CGSize size = [city.zhName sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
    return CGSizeMake(size.width + 25 + 28, 28); //left-right margin + status image size
}

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    return CGSizeMake(_collectionView.frame.size.width, 38);
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
        DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"domesticHeader" forIndexPath:indexPath];
        AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
        headerView.titleLabel.text = area.zhName;
        return headerView;
    }
    return nil;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScreenningViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [area.cities objectAtIndex:indexPath.row];
    cell.nameLabel.text = city.zhName;
//    NSLog(@"%@",_destinations.destinationsSelected);

    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        NSLog(@"%@---%@",city.cityId,cityPoi.cityId);
        if ([cityPoi.cityId isEqualToString:city.cityId]) {
            cell.nameLabel.textColor = [UIColor whiteColor];
            cell.backgroundColor = APP_THEME_COLOR;
            float a = city.lat;
            float b = city.lng;
            CLLocation *location = [[CLLocation alloc] initWithLatitude:a longitude:b];
            [self addFootprint:location];
            return  cell;
        }
    }
    cell.nameLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    cell.backgroundColor = [UIColor whiteColor];
    return  cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"event_select_city"];
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [area.cities objectAtIndex:indexPath.row];
    float a = city.lat;
    float b = city.lng;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:a longitude:b];
    BOOL find = NO;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([city.cityId isEqualToString:cityPoi.cityId]) {
            NSInteger index = [_destinations.destinationsSelected indexOfObject:cityPoi];
            [_destinations.destinationsSelected removeObjectAtIndex:index];
            [self deleteFootprint:location track:city.cityId];
            find = YES;
            break;
        }
    }
    if (!find) {
        if (_destinations.destinationsSelected.count == 0) {
            
        }
        [_destinations.destinationsSelected addObject:city];
        
        [self addFootprint:location track:city.cityId];
    }
    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
}
- (IBAction)addFootprint:(CLLocation *)location
{

    [_footprintMapCtl addPoint:location];
    
}

- (IBAction)addFootprint:(CLLocation *)location track:(NSString *)areaId
{
    NSMutableArray *tracks = [NSMutableArray array];
    [tracks addObject:areaId];
    [self changTracks:@"add" tracks:tracks];
    [_footprintMapCtl addPoint:location];
    
}
- (void)deleteFootprint:(CLLocation *)location track:(NSString *)areaId
{
    NSMutableArray *tracks = [NSMutableArray array];
    [tracks addObject:areaId];
    [self changTracks:@"del" tracks:tracks];
    [_footprintMapCtl removePoint:location];
    
}
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - http method
-(void)downloadData:(NSString *)modifiedTime url:(NSString *)url
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
    //    API_GET_DOMESTIC_DESTINATIONS
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id result = [responseObject objectForKey:@"result"];
            [_destinations.domesticCities removeAllObjects];
            [_destinations initDomesticCitiesWithJson:result];
            [_collectionView reloadData];
            
        } else {
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void)changTracks:(NSString *)action tracks:(NSArray *)tracks
{
    AccountManager *account = [AccountManager shareAccountManager];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", account.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:action forKey:@"action"];
    [params safeSetObject:tracks forKey:@"tracks"];
    NSLog(@"%@",tracks);
    NSString *urlStr = [NSString stringWithFormat:@"%@users/%@/tracks", BASE_URL, account.account.userId];
    
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
            
        } else {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end
