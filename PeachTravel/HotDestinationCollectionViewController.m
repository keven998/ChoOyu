//
//  HotDestinationCollectionViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "HotDestinationCollectionViewController.h"
#import "HotDestinationCollectionViewCell.h"
#import "HotDestinationCollectionReusableView.h"
#import "RecommendDataSource.h"
#import "CityDetailTableViewController.h"
#import "MakePlanViewController.h"
#import "ForeignViewController.h"
#import "DomesticViewController.h"
#import "Destinations.h"
#import "TaoziCollectionLayout.h"


#warning 测试景点详情数据。
#import "SpotDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"

@interface HotDestinationCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, TaoziLayoutDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HotDestinationCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderIdentifier = @"hotDestinationHeader";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    self.navigationItem.title = @"想去";
    
    [self.view addSubview:self.collectionView];

    [self.collectionView registerNib:[UINib nibWithNibName:@"HotDestinationCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HotDestinationCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderIdentifier];
    [self loadDataSource];
    
    UIBarButtonItem * makePlanBtn = [[UIBarButtonItem alloc]initWithTitle:@"新Memo" style:UIBarButtonItemStyleBordered target:self action:@selector(makePlan:)];
    makePlanBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = makePlanBtn;
}

#pragma mark - setter & getter

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        TaoziCollectionLayout *tzLayout = [[TaoziCollectionLayout alloc] init];
        tzLayout.delegate = self;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(11, 0, kWindowWidth-22, kWindowHeight-49-64) collectionViewLayout:tzLayout];
        
        _collectionView.showsVerticalScrollIndicator = NO;
        
        NSLog(@"%@", NSStringFromCGRect(self.view.bounds));
        
        _collectionView.backgroundColor = APP_PAGE_COLOR;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

#pragma mark - Private Methods

- (void)loadDataSource
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
//        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            for (id json in [responseObject objectForKey:@"result"]) {
                RecommendDataSource *data = [[RecommendDataSource alloc] initWithJsonData:json];
                [self.dataSource addObject:data];
                [self.collectionView reloadData];
            }
            [SVProgressHUD dismiss];
        } else {
//            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [SVProgressHUD dismiss];
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
    }];
    
}

#pragma mark - IBAciton Methods

- (IBAction)makePlan:(id)sender
{
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    domestic.destinations = destinations;
    foreignCtl.destinations = destinations;
    makePlanCtl.destinations = destinations;
    foreignCtl.title = @"国外";
    domestic.title = @"国内";
    makePlanCtl.viewControllers = @[domestic, foreignCtl];
    makePlanCtl.hidesBottomBarWhenPushed = YES;
    domestic.makePlanCtl = makePlanCtl;
    foreignCtl.makePlanCtl = makePlanCtl;
    domestic.notify = NO;
    foreignCtl.notify = NO;
    [_rootCtl.navigationController pushViewController:makePlanCtl animated:YES];
}


#pragma mark TaoziLayouteDelegate

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count;
}

- (CGFloat)tzcollectionLayoutWidth
{
    return self.collectionView.frame.size.width;
}

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:section];
    return recommedDataSource.localities.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            CGFloat width = ((collectionView.frame.size.width-7)/3*2);
            CGFloat heigh = width *0.75;
            size = CGSizeMake(width, heigh);
            return size;
        } else if (indexPath.row == 1) {
            CGFloat width = ((collectionView.frame.size.width-17)/3*1);
            CGFloat heigh = ((collectionView.frame.size.width-7)/3*2)*0.75;
            size = CGSizeMake(width, heigh);
            return size;
        } else {
            CGFloat width = ((collectionView.frame.size.width-20)/3);
            size = CGSizeMake(width, width);
            return size;
        }
    }
    if (indexPath.section > 0) {
        size = CGSizeMake(self.collectionView.frame.size.width/2-5, self.collectionView.frame.size.width/2-5);
        return size;
    }
    size = CGSizeMake(self.collectionView.frame.size.width/2-40, 100);
    return size;
}

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(self.collectionView.frame.size.width, 30);
    return size;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:section];
    return recommedDataSource.localities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:indexPath.section];
    Recommend *recommend = [recommedDataSource.localities objectAtIndex:indexPath.row];
    HotDestinationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell.cellImageView sd_setImageWithURL:[NSURL URLWithString:recommend.cover] placeholderImage:nil];
    cell.cellTitleLabel.text = recommend.zhName;
    cell.cellDescLabel.text = recommend.desc;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:indexPath.section];
    HotDestinationCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseHeaderIdentifier forIndexPath:indexPath];
    headerView.collectionHeaderView.text = recommedDataSource.typeName;
    return headerView;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:indexPath.section];
    Recommend *recommend = [recommedDataSource.localities objectAtIndex:indexPath.row];

    if (indexPath.row == 0) {
        RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:indexPath.section];
        Recommend *recommend = [recommedDataSource.localities objectAtIndex:indexPath.row];
        CityDetailTableViewController *cityDetailCtl = [[CityDetailTableViewController alloc] init];
        cityDetailCtl.cityId = @"5473ccd7b8ce043a64108c46";
        cityDetailCtl.hidesBottomBarWhenPushed = YES;
        [_rootCtl.navigationController pushViewController:cityDetailCtl animated:YES];
    }
    
    
    if  (indexPath.row == 1) {
        SpotDetailViewController *spotCtl = [[SpotDetailViewController alloc] init];
        spotCtl.spotId = @"5463d11b10114e2215b7e669";
        spotCtl.hidesBottomBarWhenPushed = YES;
        
        [_rootCtl.navigationController pushViewController:spotCtl animated:YES];
    }
    if (indexPath.row == 2) {
        RestaurantDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
        restaurantDetailCtl.hidesBottomBarWhenPushed = YES;
        
        [_rootCtl.navigationController pushViewController:restaurantDetailCtl animated:YES];
    }
    
    if (indexPath.row == 3) {
        ShoppingDetailViewController *shoppingCtl = [[ShoppingDetailViewController alloc] init];
        shoppingCtl.hidesBottomBarWhenPushed = YES;
        
        [_rootCtl.navigationController pushViewController:shoppingCtl animated:YES];
    }
}

@end














