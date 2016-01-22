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
#import "UploadUserAlbumViewController.h"
#import "UserAlbumOverViewTableViewController.h"
#import "UserAlbumViewController.h"
#import "UploadUserAlbumViewController.h"

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    [self updateButtonStatus];
}

- (void)setToolBar
{
    UIImageView *toolBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-49, self.view.bounds.size.width, 49)];
    toolBar.userInteractionEnabled = YES;
    toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolBar];
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(toolBar.bounds.size.width-85, 11, 60, 26)];
    _confirmBtn.layer.cornerRadius = 5.0;
    _confirmBtn.layer.borderWidth = 1.0;
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_confirmBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateDisabled];
    [_confirmBtn addTarget:self action:@selector(confirmUploadPhotos:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:_confirmBtn];
    
    _previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 9, 60, 30)];
    _previewBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_previewBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_previewBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateDisabled];
    [_previewBtn addTarget:self action:@selector(previewSelectPhotos:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:_previewBtn];
    
    [self updateButtonStatus];
}

- (void)updateButtonStatus
{
    if (_selectedPhotos.count > 0) {
        [_previewBtn setTitle:[NSString stringWithFormat:@"预览(%ld)", _selectedPhotos.count] forState:UIControlStateNormal];
        _previewBtn.enabled = YES;
        
        [_confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)", _selectedPhotos.count] forState:UIControlStateNormal];
        _confirmBtn.enabled = YES;
        _confirmBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
        
    } else {
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        _previewBtn.enabled = NO;
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        _confirmBtn.enabled = NO;
        _confirmBtn.layer.borderColor = COLOR_TEXT_II.CGColor;
    }
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = (kWindowWidth-10*2-8*3)/4;
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 49, 10);
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
            [self.dataSource insertObject:asset atIndex:0];
            
        } else if (self.dataSource.count > 0) {
            [self.collectionView reloadData];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

- (BOOL)photoIsSelected:(ALAsset *)asset
{
    for (ALAsset *tempAsset in _selectedPhotos) {
        ALAssetRepresentation* representationOne = [asset defaultRepresentation];
        ALAssetRepresentation* representationTwo = [tempAsset defaultRepresentation];
        if ([representationOne.url.absoluteString isEqualToString: representationTwo.url.absoluteString]) {
            return YES;
        }
    }
    return NO;
}

- (void)previewPhotos:(NSArray *)photos atIndex:(NSUInteger)index
{
    UserAlbumPreviewViewController *ctl = [[UserAlbumPreviewViewController alloc] init];
    ctl.showConfirmToolBar = YES;
    ctl.currentIndex = index;
    ctl.dataSource = _dataSource;
    ctl.selectedPhotos = self.selectedPhotos;
    [self.navigationController pushViewController: ctl animated:YES];
}

#pragma mark - IBAction Methods

- (void)selectPhoto:(UIButton *)sender
{
    ALAsset *asset = _dataSource[sender.tag];
    if ([self photoIsSelected:asset]) {
        [self removeAssetFromSelectedPhotos:asset];
    } else {
        [_selectedPhotos addObject:asset];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [self updateButtonStatus];
}

- (void)removeAssetFromSelectedPhotos:(ALAsset *)asset
{
    for (ALAsset *tempAsset in _selectedPhotos) {
        ALAssetRepresentation* representationOne = [asset defaultRepresentation];
        ALAssetRepresentation* representationTwo = [tempAsset defaultRepresentation];
        if ([representationOne.url.absoluteString isEqualToString: representationTwo.url.absoluteString]) {
            [_selectedPhotos removeObject:tempAsset];
            return;
        }
    }
}

- (void)previewSelectPhotos:(UIButton *)sender
{
    [self previewPhotos:_selectedPhotos atIndex:0];
}

- (void)confirmUploadPhotos:(id)sender
{
    UIViewController *ctl = self.navigationController.viewControllers.firstObject;
    [ctl dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:uploadUserAlbumNoti object:nil userInfo:@{@"images" : _selectedPhotos}];
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
    cell.selectBtn.tag = indexPath.row;
    [cell.selectBtn addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectBtn.selected = [self photoIsSelected:_dataSource[indexPath.row]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self previewPhotos:_dataSource atIndex:indexPath.row];
}


@end
