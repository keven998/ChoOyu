//
//  UserAlbumReviewViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "UserAlbumReviewViewController.h"
#import "UserAlbumPreviewCollectionViewCell.h"

@interface UserAlbumReviewViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *descScrollView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, copy) NSString *naviTitle;
@property (nonatomic, copy) NSString *imageDesc;

@end

@implementation UserAlbumReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_white_style.png"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    
    self.view.backgroundColor = COLOR_TEXT_I;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition: UICollectionViewScrollPositionLeft animated:NO];
    [self.view addSubview:self.descScrollView];
    
    self.naviTitle = [NSString stringWithFormat:@"%ld/%ld", _currentIndex+1, _dataSource.count];
    AlbumImageModel *image = [_dataSource objectAtIndex:_currentIndex];
    image.imageDesc = @"我特别喜欢大海，哈哈，这个大海这个烂啊，我很陶醉，我很喜欢滑翔，很装逼，带我装逼带我飞";
    _descLabel.text = image.imageDesc;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [self.navigationController.navigationBar setBackgroundImage:[ConvertMethods createImageWithColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObject:COLOR_TEXT_I forKey:NSForegroundColorAttributeName]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navi_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forBarMetrics:UIBarMetricsDefault];
}

- (void)goBack
{
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setDataSource:(NSMutableArray *)dataSource
{
    _dataSource = dataSource;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    _currentIndex = currentIndex;
    self.naviTitle = [NSString stringWithFormat:@"%ld/%ld", _currentIndex+1, _dataSource.count];
    AlbumImageModel *image = [_dataSource objectAtIndex:_currentIndex];
    image.imageDesc = @"我特别喜欢大海，哈哈，这个大海这个烂啊，我很陶醉，我很喜欢滑翔，很装逼，带我装逼带我飞";
    _descLabel.text = image.imageDesc;
}

- (void)setNaviTitle:(NSString *)naviTitle
{
    _naviTitle = naviTitle;
    self.navigationItem.title = _naviTitle;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = COLOR_TEXT_I;
        [_collectionView registerNib:[UINib nibWithNibName:@"UserAlbumPreviewCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"userAlbumPreviewCell"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
    }
    return _collectionView;
}

- (UIScrollView *)descScrollView
{
    if (!_descScrollView) {
        _descScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-140, self.view.bounds.size.width, 140)];
        _descScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.15];
        [_descScrollView addSubview:self.descLabel];
    }
    return _descScrollView;
}

- (UILabel *)descLabel
{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.descScrollView.bounds.size.width-40, 120)];
        _descLabel.numberOfLines = 0;
        _descLabel.font = [UIFont systemFontOfSize:14.0];
        _descLabel.textColor = [UIColor whiteColor];
    }
    return _descLabel;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserAlbumPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userAlbumPreviewCell" forIndexPath:indexPath];
    AlbumImageModel *imageModel = [_dataSource objectAtIndex:indexPath.row];
    cell.mainView.backgroundColor = COLOR_TEXT_I;
    [cell.mainView.imageView sd_setImageWithURL:[NSURL URLWithString:imageModel.imageUrl]];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentIndex = scrollView.contentOffset.x/_collectionView.bounds.size.width;
}


@end


