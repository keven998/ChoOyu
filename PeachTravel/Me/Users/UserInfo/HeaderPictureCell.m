//
//  HeaderPictureCell.m
//  PeachTravel
//
//  Created by dapiao on 15/5/3.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "HeaderPictureCell.h"
#import "TaoziCollectionLayout.h"
#import "PicCell.h"
#import "PXAlertView+Customization.h"
@interface HeaderPictureCell ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>


@end
@implementation HeaderPictureCell

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

    _collectionView.delegate = self;
    _collectionView.dataSource = self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    if (section == _showCitiesIndex) {
    return _headerPicArray.count + 1;
    //    }
    //    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"cell";
    PicCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row == _headerPicArray.count) {
        cell.picImage.image =[UIImage imageNamed:@"ic_userInfo_avatar_placeholder"];
    } else {
        [cell.picImage sd_setImageWithURL:[NSURL URLWithString:_headerPicArray[indexPath.row]]];
    }
    return cell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _headerPicArray.count) {
        return CGSizeMake(97.5, 85);
    } else {
        return CGSizeMake(132, 85);
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _headerPicArray.count) {
        [self.delegate showPickerView];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
