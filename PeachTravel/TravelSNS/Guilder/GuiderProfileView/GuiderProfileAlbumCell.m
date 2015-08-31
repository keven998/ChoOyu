//
//  GuiderProfileAlbumCell.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileAlbumCell.h"
#import "AlbumImageCell.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

#define ProfileAbumID @"albumImageCell"

@interface GuiderProfileAlbumCell ()

@property (nonatomic, strong) UIImageView *albumImage;

@end

@implementation GuiderProfileAlbumCell

#pragma mark - lifeCycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupAlbum];
    }
    return self;
}

// 设置相册
- (void)setupAlbum {
    
    // 1.标题
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"个人相册";
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab = titleLab;
    [self addSubview:titleLab];
    
    // 2.相册图片数量
    UILabel *albumCount = [[UILabel alloc] init];
    albumCount.text = @"66";
    albumCount.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    albumCount.font = [UIFont boldSystemFontOfSize:36.0];
    albumCount.textAlignment = NSTextAlignmentCenter;
    self.albumCount = albumCount;
    [self addSubview:albumCount];
    
    // 3.相册列表
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(80, 80);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerNib:[UINib nibWithNibName:@"AlbumImageCell" bundle:nil] forCellWithReuseIdentifier:ProfileAbumID];
    self.collectionView = collectionView;
    [self addSubview:collectionView];
    
    // 4.照片
    UIImageView *albumImage = [[UIImageView alloc] init];
    albumImage.backgroundColor = [UIColor greenColor];
    
    self.albumImage = albumImage;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLab.frame = CGRectMake(0, 0, kWindowWidth, 50);
    self.albumCount.frame = CGRectMake(10, CGRectGetMaxY(self.titleLab.frame), 70, 80);
    self.collectionView.frame = CGRectMake(CGRectGetMaxX(self.albumCount.frame), CGRectGetMaxY(self.titleLab.frame), kWindowWidth - 140, 80);
    
    self.albumImage.frame = CGRectMake(0, 0, 80, 80);
}

#pragma mark - 实现数据源方法和代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.albumArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ProfileAbumID forIndexPath:indexPath];
    
    AlbumImage *image = [_albumArray objectAtIndex:indexPath.row];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:((AlbumImage *)image).image.imageUrl] placeholderImage:[UIImage imageNamed:@"ic_home_default_avatar.png"]];
    

    return cell;
}

// 选中某一张图片
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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

// 刷新数据
- (void)setAlbumArray:(NSArray *)albumArray
{
    _albumArray = albumArray;
    
    [self.collectionView reloadData];
    
    self.albumCount.text = [NSString stringWithFormat:@"%ld",self.albumArray.count];
}

@end