//
//  UserAlbumSelectViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/17/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "UserAlbumSelectViewController.h"
#import "UserAlbumSelectCollectionViewCell.h"
#import "UserAlbumPreviewViewController.h"

@interface UserAlbumSelectViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIButton *previewBtn;

@end

@implementation UserAlbumSelectViewController

static NSString * const reuseIdentifier = @"userAlbumSelectCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self setToolBar];
    [self loadDataSource];
}

- (void)setToolBar
{
    UIImageView *toolBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-49, self.view.bounds.size.width, 49)];
    toolBar.userInteractionEnabled = YES;
    toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolBar];
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(toolBar.bounds.size.width-85, 9, 60, 30)];
    _confirmBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
    _confirmBtn.layer.cornerRadius = 5.0;
    _confirmBtn.layer.borderWidth = 1.0;
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [toolBar addSubview:_confirmBtn];
    
    _previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 9, 60, 30)];
    [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    [_previewBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [toolBar addSubview:_previewBtn];
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = (kWindowWidth-10*2-8*3)/4;
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
        layout.minimumLineSpacing = 8;
        layout.minimumInteritemSpacing = 8;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = APP_PAGE_COLOR;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"UserAlbumSelectCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];

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

- (void)loadDataSource {
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        
        if (asset) {
            [self.dataSource addObject:asset];
            
        } else if (self.dataSource.count > 0) {
            [self.collectionView reloadData];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserAlbumSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.asset = _dataSource[indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserAlbumPreviewViewController *ctl = [[UserAlbumPreviewViewController alloc] init];
    ctl.currentIndex = indexPath.row;
    ctl.dataSource = _dataSource;
    [self.navigationController pushViewController: ctl animated:YES];
}


@end
