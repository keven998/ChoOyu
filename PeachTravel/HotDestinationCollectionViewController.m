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
#import "DestinationViewController.h"
#import "MakePlanViewController.h"
#import "ForeignViewController.h"
#import "DomesticViewController.h"

#warning 测试景点详情数据。
#import "SpotDetailViewController.h"

@interface HotDestinationCollectionViewController ()
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation HotDestinationCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderIdentifier = @"hotDestinationHeader";



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"HotDestinationCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HotDestinationCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderIdentifier];
    self.collectionView.collectionViewLayout = self.flowLayout;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    [self loadDataSource];
    
    UIButton *makePlanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [makePlanBtn setTitle:@"做攻略" forState:UIControlStateNormal];
    makePlanBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [makePlanBtn setTitleColor:UIColorFromRGB(0xee528c) forState:UIControlStateNormal];
    [makePlanBtn addTarget:self action:@selector(makePlan:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:makePlanBtn];

}

#pragma mark - setter & getter

- (UICollectionViewLayout *)flowLayout
{
    CGFloat width = self.view.bounds.size.width;
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake((width-40)/2, (width-40)/2);
        _flowLayout.minimumInteritemSpacing = 10.;
        _flowLayout.minimumLineSpacing = 10.;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        [_flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _flowLayout.headerReferenceSize = CGSizeMake(width, 40);
    }
    
    return _flowLayout;
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
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            for (id json in [responseObject objectForKey:@"result"]) {
                RecommendDataSource *data = [[RecommendDataSource alloc] initWithJsonData:json];
                [self.dataSource addObject:data];
                [self.collectionView reloadData];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
    }];

}

#pragma mark - IBAciton Methods

- (IBAction)makePlan:(id)sender
{
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    foreignCtl.title = @"国外";
    domestic.title = @"国内";
    makePlanCtl.viewControllers = @[domestic, foreignCtl];
    makePlanCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:makePlanCtl animated:YES];
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
    CityDetailTableViewController *cityDetailCtl = [[CityDetailTableViewController alloc] init];
    cityDetailCtl.recommend = recommend;
    cityDetailCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cityDetailCtl animated:YES];
    
/*
    SpotDetailViewController *spotCtl = [[SpotDetailViewController alloc] init];
    [self.navigationController pushViewController:spotCtl animated:YES];
 */
}

@end














