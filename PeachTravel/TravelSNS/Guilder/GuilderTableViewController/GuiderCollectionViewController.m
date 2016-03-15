//
//  GuiderCollectionViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderCollectionViewController.h"
#import "PeachTravel-swift.h"
#import "GuiderDistribute.h"
#import "GuiderProfileViewController.h"
#import "ExpertManager.h"
#import "ExpertCollectionCell.h"
@interface GuiderCollectionViewController ()

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation GuiderCollectionViewController

static NSString * const reuseIdentifier = @"expertCell";
static NSString * const reuseIdentifierHeader = @"expertCellHeader";

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    self.collectionView.backgroundColor = APP_PAGE_COLOR;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 20;
    layout.footerReferenceSize = CGSizeMake(kWindowWidth, 16);
    
    layout.itemSize = CGSizeMake(self.view.bounds.size.width, 150);
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"ExpertCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseIdentifierHeader];
    
    // 传入的时候刷新即可
    [self loadTravelers:_distributionArea withPageNo:0];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

// 传递模型的时候给导航栏标题赋值
- (void)setGuiderDistribute:(GuiderDistribute *)guiderDistribute
{
    _guiderDistribute = guiderDistribute;
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal_hilighted"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 200, 18)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:16];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    nameLabel.text = [NSString stringWithFormat:@"~派派 · %@ · 达人~",guiderDistribute.zhName];
    [view addSubview:nameLabel];
    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, 200, 12)];
    idLabel.textColor = [UIColor whiteColor];
    idLabel.font = [UIFont boldSystemFontOfSize:10];
    idLabel.textAlignment = NSTextAlignmentCenter;
    idLabel.text = [NSString stringWithFormat:@"%ld位",guiderDistribute.expertCnt];
    [view addSubview:idLabel];
    self.navigationItem.titleView = view;
    
    // 传入国家ID数据时刷新表格
    [self loadTravelers:guiderDistribute.ID withPageNo:0];
}

#pragma mark - http method

- (void)loadTravelers:(NSString *)areaId withPageNo:(NSInteger)page
{
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(GuiderCollectionViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf content:64];
    [ExpertManager asyncLoadExpertsWithAreaId:areaId page:page pageSize:15 completionBlock:^(BOOL isSuccess, NSArray *expertsArray) {
        [hud hideTZHUD];
        if (isSuccess) {
            _dataSource = expertsArray;
            NSLog(@"%@",expertsArray);
            [self.collectionView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus: HTTP_FAILED_HINT];
        }
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 初始化cell并对cell赋值
    ExpertCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // 达人模型,dataSource是达人列表数组
    ExpertModel * expert = self.dataSource[indexPath.section];
    cell.guiderModel = expert;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GuiderProfileViewController *guiderCtl = [[GuiderProfileViewController alloc] init];
    FrendModel *model = _dataSource[indexPath.section];
    guiderCtl.userId = model.userId;
    guiderCtl.shouldShowExpertTipsView = YES;
    [self.navigationController pushViewController:guiderCtl animated:YES];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseIdentifierHeader forIndexPath:indexPath];
    header.backgroundColor = APP_PAGE_COLOR;
    return header;
}

- (void)goBack
{
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
