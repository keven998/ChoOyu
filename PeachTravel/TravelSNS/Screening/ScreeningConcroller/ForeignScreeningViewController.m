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
//#import "ScreenningViewCell.h"
#import "DomesticDestinationCell.h"
@interface ForeignScreeningViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,TaoziLayoutDelegate,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *_dataArray;
    UICollectionView *_collectionView;
}
@end

@implementation ForeignScreeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [[NSMutableArray alloc]init];
    
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

//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:@"Cache-Control" forHTTPHeaderField:@"private"];
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
    TaoziCollectionLayout *layout = (TaoziCollectionLayout *)_collectionView.collectionViewLayout;
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    _collectionView=[[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    
    //注册Cell，必须要有
//    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"DomesticDestinationCell" bundle:nil]  forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.view addSubview:_collectionView];
    layout.delegate = self;
    layout.showDecorationView = YES;
    layout.margin = 10;
    layout.spacePerItem = 10;
    layout.spacePerLine = 10;
//
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置其布局方向
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);//设置其边界
    
}

#pragma mark - TaoziLayoutDelegate

//- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(self.foreignCollectionView.frame.size.width, 38);
//}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    AreaDestination *country = _destinations.foreignCountries[indexPath.section];
    ScreeningModel *city = _dataArray[indexPath.row];
    CGSize size = [city.zhName sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
    NSLog(@"----%@",city.zhName);
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
    static NSString * CellIdentifier = @"UICollectionViewCell";
    DomesticDestinationCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    ScreeningModel *model = _dataArray[indexPath.row];
    NSLog(@"model%@",model);
    cell.backgroundColor = [UIColor orangeColor];
//    cell.tiltleLabel.text = model.zhName;
    
    return cell;
}



@end
