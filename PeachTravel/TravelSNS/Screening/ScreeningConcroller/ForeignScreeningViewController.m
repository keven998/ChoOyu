//
//  ForeignScreeningViewController.m
//  
//
//  Created by dapiao on 15/4/28.
//
//

#import "ForeignScreeningViewController.h"
#import "TaoziCollectionLayout.h"
#import "ScreeningModel.h"
//#import "ScreeningCell.h"
#import "ScreenningViewCell.h"
#import "DomesticDestinationCell.h"
@interface ForeignScreeningViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,TaoziLayoutDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ForeignScreeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [[NSMutableArray alloc]init];
    [self.view addSubview:self.collectionView];
    [self downloadData];
}

-(void)downloadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    __weak typeof(self)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?abroad=false",API_GET_SCREENING];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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


-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
        layout.delegate = self;
        layout.showDecorationView = NO;
        layout.delegate = self;
        layout.showDecorationView = YES;
        layout.margin = 10;
        layout.spacePerItem = 10;
        layout.spacePerLine = 10;

        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64);
        _collectionView=[[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        [_collectionView registerNib:[UINib nibWithNibName:@"ScreenningViewCell" bundle:nil]  forCellWithReuseIdentifier:@"cell"];
             _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
   
    return _collectionView;
}

#pragma mark - TaoziLayoutDelegate

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
    return _dataArray.count;
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
    cell.tag = 100 + indexPath.row;
    cell.nameLabel.text = model.zhName;
    cell.nameLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    cell.backgroundColor = [UIColor whiteColor];

    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScreeningModel *model = _dataArray[indexPath.row];
    ScreenningViewCell *cell = (ScreenningViewCell *)[self.view viewWithTag:(100+indexPath.row)];
    cell.backgroundColor = APP_THEME_COLOR;
    cell.nameLabel.textColor = [UIColor whiteColor];
    [self.screeningVC.selectedCityArray addObject:model.userId];
    [self.screeningVC doScreening];
}

@end
