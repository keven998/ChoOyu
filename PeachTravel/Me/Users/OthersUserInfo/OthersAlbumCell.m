//
//  OthersAlbumCell.m
//  PeachTravel
//
//  Created by dapiao on 15/5/18.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "OthersAlbumCell.h"
#import "PicCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
@interface OthersAlbumCell ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end

@implementation OthersAlbumCell

- (void)awakeFromNib
{
    [self createUI];
}

-(void)createUI
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 5;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    [_collectionView setCollectionViewLayout:layout];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    _collectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
    [_collectionView registerNib:[UINib nibWithNibName:@"PicCell" bundle:nil]  forCellWithReuseIdentifier:@"cell"];
    
    [self.contentView addSubview:_collectionView];
}

- (void)setHeaderPicArray:(NSArray *)headerPicArray
{
    _headerPicArray = headerPicArray;
    [_collectionView reloadData];
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _headerPicArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"cell";
    PicCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    AlbumImageModel *albumImage = _headerPicArray[indexPath.row];
    [cell.picImage sd_setImageWithURL:[NSURL URLWithString: albumImage.imageUrl]];
    return cell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(132, 85);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = _headerPicArray.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        AlbumImageModel *albumImage = _headerPicArray[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = albumImage.imageUrl; // 图片路径
        
        

        NSIndexPath *picIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        PicCell *picCell = (PicCell *)[_collectionView cellForItemAtIndexPath:picIndexPath];
        photo.srcImageView = picCell.picImage;

        //        photo.srcImageView = (UIImageView *)[swipeView itemViewAtIndex:index]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

@end
