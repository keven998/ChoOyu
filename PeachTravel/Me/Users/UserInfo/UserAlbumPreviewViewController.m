//
//  UserAlbumPreviewViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "UserAlbumPreviewViewController.h"
#import "UserAlbumPreviewCollectionViewCell.h"

@interface UserAlbumPreviewViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton *selectBtn;

@end

@implementation UserAlbumPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition: UICollectionViewScrollPositionLeft animated:NO];
    
    _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_selectBtn setImage:[UIImage imageNamed:@"icon_photo_normal.png"] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:@"icon_photo_selected.png"] forState:UIControlStateSelected];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_selectBtn];
    [_selectBtn addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    _selectBtn.selected = [self photoIsSelected:_dataSource[_currentIndex]];
}

- (void)setDataSource:(NSMutableArray *)dataSource
{
    _dataSource = dataSource;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    _currentIndex = currentIndex;
    _selectBtn.selected = [self photoIsSelected:_dataSource[_currentIndex]];
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-49);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-49) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"UserAlbumPreviewCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"userAlbumPreviewCell"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
    }
    return _collectionView;
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


#pragma mark - IBAction Methods

- (void)selectPhoto:(UIButton *)sender
{
    ALAsset *asset = _dataSource[_currentIndex];
    if ([self photoIsSelected:asset]) {
        [self.selectedPhotos removeObject:asset];
        _selectBtn.selected = NO;
    } else {
        [self.selectedPhotos addObject:asset];
        _selectBtn.selected = YES;
    }
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
    ALAsset *asset = [_dataSource objectAtIndex:indexPath.row];
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    CGImageRef ref = [representation fullScreenImage];
    cell.mainView.image = [UIImage imageWithCGImage:ref];
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








