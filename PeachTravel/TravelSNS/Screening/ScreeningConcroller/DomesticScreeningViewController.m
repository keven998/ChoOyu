//
//  DomesticScreeningViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/4/28.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "DomesticScreeningViewController.h"
#import "TaoziCollectionLayout.h"
#import "ScreeningModel.h"
//#import "ScreeningCell.h"
#import "ScreenningViewCell.h"
#import "DomesticDestinationCell.h"
@interface DomesticScreeningViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,TaoziLayoutDelegate>
{
    NSMutableArray *_dataArray;
    UICollectionView *_collectionView;
}
@end

@implementation DomesticScreeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [[NSMutableArray alloc]init];
    _collectionView.allowsMultipleSelection = YES;
    [self downloadData];
    [self createCollectionView];
}
-(void)downloadData
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    TZProgressHUD *hud = [[TZProgressHUD alloc]init];
    [hud showHUD];
    
    [manager GET:API_GET_SCREENING parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dataDict = dict[@"result"];
        NSDictionary *domestic = dataDict[@"中国"];
        
        for (NSDictionary *dicdic in domestic) {
            
            ScreeningModel *model = [[ScreeningModel alloc]init];
            model.zhName = dicdic[@"zhName"];
            model.userId = dicdic[@"id"];
            [_dataArray addObject:model];
        }
        
        [_collectionView reloadData];
        [hud hideTZHUD];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
    }];
    
}
-(void)createCollectionView
{
    TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
    layout.delegate = self;
    
    _collectionView=[[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    
    //注册Cell，必须要有
    //    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    //    [_collectionView registerNib:[UINib nibWithNibName:@"DomesticDestinationCell" bundle:nil]  forCellWithReuseIdentifier:@"cell"];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"ScreenningViewCell" bundle:nil]  forCellWithReuseIdentifier:@"cell"];
    
    [self.view addSubview:_collectionView];
    layout.delegate = self;
    layout.showDecorationView = YES;
    layout.margin = 10;
    layout.spacePerItem = 10;
    layout.spacePerLine = 10;
    //
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
}

#pragma mark - TaoziLayoutDelegate

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
//    return CGSizeMake(_collectionView.frame.size.width, 38);
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    AreaDestination *country = _destinations.foreignCountries[indexPath.section];
    ScreeningModel *city = _dataArray[indexPath.row];
    CGSize size = [city.zhName sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
    return CGSizeMake(size.width + 25 + 28, 28);;
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tzcollectionLayoutWidth
{
    return _collectionView.frame.size.width;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    if (section == _showCitiesIndex) {
    return _dataArray.count;
    //    }
    //    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"cell";
    ScreenningViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    ScreeningModel *model = _dataArray[indexPath.row];
    cell.nameLabel.text = model.zhName;
    if (cell.selected) {
        cell.nameLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = APP_THEME_COLOR;
        return  cell;
    }
    cell.nameLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    cell.backgroundColor = [UIColor whiteColor];

    
    //    cell.tiltleLabel.backgroundColor = [UIColor grayColor];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"%@",cell)
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = YES;

    NSLog(@"%@",_screeningVC.selectedCityArray);
}
@end
