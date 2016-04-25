//
//  BNServerCityHomeViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/22/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNServerCityHomeViewController.h"
#import "DestinationCollectionViewCell.h"
#import "BNSelectServerCityViewController.h"
#import "StoreManager.h"

@interface BNServerCityHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, BNSelectServerCityViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *selectPanel;

@end

@implementation BNServerCityHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"订阅服务城市";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 84, kWindowWidth-24, 20)];
    titleLabel.numberOfLines = 0;
    titleLabel.text = @"当前订阅城市";
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.textColor = COLOR_TEXT_II;
    [self.view addSubview:titleLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 170, kWindowWidth-24, 100)];
    contentLabel.numberOfLines = 0;
    contentLabel.text = @"旅行派APP重磅推出\"定制\"功能了，为了方便您能迅速抢单，请先订阅服务城市~\n当有买家发布悬赏旅游需求时，平台将会根据您订阅的城市及时推送消息给您~";
    contentLabel.font = [UIFont systemFontOfSize:15.0];
    contentLabel.textColor = COLOR_TEXT_II;
    [self.view addSubview:contentLabel];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(100, kWindowHeight-100, kWindowWidth-200, 45)];
    [addButton setTitle:@"去添加城市" forState: UIControlStateNormal];
    [addButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    addButton.layer.borderColor = APP_THEME_COLOR.CGColor;
    addButton.layer.borderWidth = 0.5;
    addButton.layer.cornerRadius = 3.0;
    [addButton addTarget:self action:@selector(addServerCity) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:addButton];
    
    [self setupSelectPanel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [_selectPanel reloadData];
}

- (void)addServerCity
{
    BNSelectServerCityViewController *ctl = [[BNSelectServerCityViewController alloc] init];
    ctl.delegate = self;
    ctl.selectCitys = _selectCitys;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)didSelectCitys:(NSArray *)cityList
{
    [StoreManager asyncUpdateSellerServerCities:cityList completionBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"修改成功"];
            _selectCitys = cityList;
            [_selectPanel reloadData];
        } else {
            [SVProgressHUD showHint:@"修改失败"];
        }
    }];
}
- (void)setupSelectPanel
{
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 110, kWindowWidth, 49)];
    toolBar.layer.shadowColor = COLOR_LINE.CGColor;
    toolBar.layer.shadowOffset = CGSizeMake(0, -1.0);
    toolBar.layer.shadowOpacity = 0.33;
    toolBar.layer.shadowRadius = 1.0;
    toolBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:toolBar];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    aFlowLayout.minimumInteritemSpacing = 0;
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.selectPanel = [[UICollectionView alloc] initWithFrame:toolBar.bounds collectionViewLayout:aFlowLayout];
    [self.selectPanel setBackgroundColor:[UIColor whiteColor]];
    self.selectPanel.showsHorizontalScrollIndicator = NO;
    self.selectPanel.showsVerticalScrollIndicator = NO;
    self.selectPanel.delegate = self;
    self.selectPanel.dataSource = self;
    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.selectPanel registerNib:[UINib nibWithNibName:@"DestinationCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [toolBar addSubview:_selectPanel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _selectCitys.count;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DestinationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    CityDestinationPoi *city = [_selectCitys objectAtIndex:indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld.%@", (long)(indexPath.row + 1), city.zhName];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CityDestinationPoi *city = [_selectCitys objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@"%ld.%@", (long)(indexPath.row + 1), city.zhName];
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    NSLog(@"%@", NSStringFromCGSize(size));
    return CGSizeMake(size.width, 28);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 14;
}

@end
