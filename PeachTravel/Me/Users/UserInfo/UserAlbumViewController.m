//
//  UserAlbumViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/2/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "UserAlbumViewController.h"
#import "AlbumImageCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

@interface UserAlbumViewController ()

@end

@implementation UserAlbumViewController

static NSString * const reuseIdentifier = @"albumImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.view.bounds.size.width/4, (self.view.bounds.size.width/4));
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [self.collectionView registerNib:[UINib nibWithNibName:@"AlbumImageCell" bundle:nil]forCellWithReuseIdentifier:@"albumImageCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _albumArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    AlbumImage *image = [_albumArray objectAtIndex:indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:image.image.imageUrl] placeholderImage:nil];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumImageCell *cell = (AlbumImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSInteger count = _albumArray.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        AlbumImage *album = [_albumArray objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = album.image.imageUrl; // 图片路径
        photo.srcImageView = (UIImageView *)cell.imageView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

@end













