//
//  GuiderCollectionViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderCollectionViewController.h"
#import "GuiderCollectionCell.h"
#import "PeachTravel-swift.h"
#import "OtherUserInfoViewController.h"
#import "GuiderDistribute.h"
#import "GuiderProfileViewController.h"
#import "GuilderManager.h"

@interface GuiderCollectionViewController ()

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation GuiderCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    self.collectionView.backgroundColor = APP_PAGE_COLOR;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 20;
    
    layout.itemSize = CGSizeMake(self.view.bounds.size.width, 540);
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"GuiderCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    // 传入的时候刷新即可
    [self loadTravelers:_distributionArea withPageNo:0];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_lxp_guide_lists"];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_lxp_guide_lists"];
    
}

// 传递模型的时候给导航栏标题赋值
- (void)setGuiderDistribute:(GuiderDistribute *)guiderDistribute
{
    _guiderDistribute = guiderDistribute;
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
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
    [GuilderManager asyncLoadGuidersWithAreaId:areaId page:page pageSize:15 completionBlock:^(BOOL isSuccess, NSArray *guiderArray) {
        [hud hideTZHUD];
        if (isSuccess) {
            _dataSource = guiderArray;
            [self.collectionView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus: HTTP_FAILED_HINT];
        }
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 初始化cell并对cell赋值
    GuiderCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // 达人模型,dataSource是达人列表数组
    FrendModel * frend = self.dataSource[indexPath.row];
    cell.guiderModel = frend;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    OtherUserInfoViewController *otherInfoCtl = [[OtherUserInfoViewController alloc]init];
    FrendModel *model = _dataSource[indexPath.row];
    //    otherInfoCtl.model = model;
    otherInfoCtl.userId = model.userId;
    otherInfoCtl.shouldShowExpertTipsView = YES;
    [self.navigationController pushViewController:otherInfoCtl animated:YES];
     */
    
    GuiderProfileViewController *guiderCtl = [[GuiderProfileViewController alloc] init];
    FrendModel *model = _dataSource[indexPath.row];
    guiderCtl.userId = model.userId;
    guiderCtl.shouldShowExpertTipsView = YES;
    [self.navigationController pushViewController:guiderCtl animated:YES];
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
