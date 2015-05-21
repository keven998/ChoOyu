//
//  OthersAlbumCell.m
//  PeachTravel
//
//  Created by dapiao on 15/5/18.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "OthersAlbumCell.h"
#import "PicCell.h"

@interface OthersAlbumCell ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>


@end

@implementation OthersAlbumCell

- (void)awakeFromNib {
    [self createUI];
}
-(void)createUI
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 5;
    
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    [_collectionView setCollectionViewLayout:layout];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    _collectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
    [_collectionView registerNib:[UINib nibWithNibName:@"PicCell" bundle:nil]  forCellWithReuseIdentifier:@"cell"];
    
    [self.contentView addSubview:_collectionView];
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
    [cell.picImage sd_setImageWithURL:[NSURL URLWithString:_headerPicArray[indexPath.row]]];
    return cell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(132, 85);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
}

@end
