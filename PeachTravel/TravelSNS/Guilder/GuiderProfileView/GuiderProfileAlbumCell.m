//
//  GuiderProfileAlbumCell.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileAlbumCell.h"

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
    albumCount.textAlignment = NSTextAlignmentCenter;
    self.albumCount = albumCount;
    [self addSubview:albumCount];
    
    // 3.相册列表
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView = collectionView;
    [self addSubview:collectionView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLab.frame = CGRectMake(0, 0, kWindowWidth, 50);
    self.albumCount.frame = CGRectMake(0, CGRectGetMaxY(self.titleLab.frame), 80, 80);
    self.collectionView.frame = CGRectMake(CGRectGetMaxX(self.albumCount.frame), CGRectGetMaxY(self.titleLab.frame), kWindowWidth - 80, 80);
}

@end
