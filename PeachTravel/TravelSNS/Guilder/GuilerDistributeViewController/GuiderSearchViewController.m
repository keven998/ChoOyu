//
//  GuiderSearchViewController.m
//  PeachTravel
//
//  Created by 王聪 on 15/8/27.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuiderSearchViewController.h"
#import "FrendRequestTableViewController.h"
#import "ContactListTableViewCell.h"
#import "AccountManager.h"
#import "ChatViewController.h"
#import "ExpertManager.h"
#import "GuiderProfileViewController.h"
#import "ExpertCollectionCell.h"

@interface GuiderSearchViewController () <UISearchBarDelegate, UISearchControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SWTableViewCellDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSArray * dataSource;

@end


static NSString * const reuseIdentifier = @"expertCell";
static NSString * const reuseIdentifierHeader = @"expertCellHeader";

@implementation GuiderSearchViewController

- (NSArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSArray array];
    }
    return _dataSource;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"输入“国家、城市” 搜索达人..."];
    _searchBar.tintColor = COLOR_TEXT_II;
    _searchBar.showsCancelButton = YES;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"icon_search_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [_searchBar setTranslucent:YES];
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.navigationItem.titleView = _searchBar;
    
    UIImageView *imageBg = [[UIImageView alloc]initWithFrame:CGRectMake((kWindowWidth - 210)/2, 68, 210, 130)];
    
    imageBg.image = [UIImage imageNamed:@"search_default_background"];
    
    
    self.collectionView.backgroundColor = APP_PAGE_COLOR;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 20;
    layout.footerReferenceSize = CGSizeMake(kWindowWidth, 16);
    
    layout.itemSize = CGSizeMake(self.view.bounds.size.width, 150);
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"ExpertCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseIdentifierHeader];
    
    [_searchBar becomeFirstResponder];
    
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_searchBar endEditing:YES];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:YES];
}


#pragma mark - 实现SearchBar的代理方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"点击了搜索按钮");
    [self loadTravelers:searchBar.text withPageNo:0];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 加载网络数据
- (void)loadTravelers:(NSString *)areaName withPageNo:(NSInteger)page
{
    [SVProgressHUD show];
    [ExpertManager asyncLoadExpertsWithAreaName:areaName page:page pageSize:15 completionBlock:^(BOOL isSuccess, NSArray *expertsArray) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"加载完成"];
            _dataSource = expertsArray;
            [self.collectionView reloadData];
            [self.searchBar endEditing:YES];
        } else {
            NSString *tip = [NSString stringWithFormat:@"还没有达人去过%@",areaName];
            [SVProgressHUD showErrorWithStatus:tip];
            [self.searchBar endEditing:YES];
        }
    }];
}


#pragma mark - 输入文字时刷新表格数据

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.searchBar endEditing:YES];
}


@end
