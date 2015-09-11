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
    titleLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
    titleLab.textColor = UIColorFromRGB(0x646464);
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab = titleLab;
    [self addSubview:titleLab];
    
    // 2.相册图片数量
    UILabel *albumCount = [[UILabel alloc] init];
    albumCount.text = @"66";
    albumCount.textColor = UIColorFromRGB(0xC7C7C7);
    albumCount.font = [UIFont boldSystemFontOfSize:30.0];
    albumCount.textAlignment = NSTextAlignmentRight;
    self.albumCount = albumCount;
//    [self addSubview:albumCount];
    
    // 3.相册列表
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = (kWindowWidth-10-20) / 3;
    flowLayout.itemSize = CGSizeMake(itemW, itemW);
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
    
    // 5.右边箭头
    UIButton *arrowBtn = [[UIButton alloc] init];
//    arrowBtn.backgroundColor = [UIColor redColor];
    [arrowBtn setImage:[UIImage imageNamed:@"album_arrow"] forState:UIControlStateNormal];
    self.arrowBtn = arrowBtn;
    [self addSubview:arrowBtn];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat collectionW = (kWindowWidth-8-23) / 3;
    self.collectionView.frame = CGRectMake(8, 10, kWindowWidth - 31, collectionW);
    
    self.albumImage.frame = CGRectMake(0, 0, collectionW, collectionW);
    self.arrowBtn.frame = CGRectMake(kWindowWidth-23, (self.frame.size.height-23)*0.5, 23, 23);
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
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:((AlbumImage *)image).image.imageUrl] placeholderImage:[UIImage imageNamed:@"picture"]];
    

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
