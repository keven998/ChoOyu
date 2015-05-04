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
@interface HeaderPictureCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,TaoziLayoutDelegate>


@end
@implementation HeaderPictureCell

- (void)awakeFromNib {
    // Initialization code
    [self createUI];


}
-(void)createUI
{
    //    TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
    //    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, 14, 100, 15)];
    //    na
    //    [self.contentView addSubview:nameLabel];
    
    
    
    TaoziCollectionLayout *layout = (TaoziCollectionLayout *)_collectionView.collectionViewLayout;
    layout.delegate = self;
    
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    _collectionView.scrollEnabled = NO;
    
    [_collectionView registerNib:[UINib nibWithNibName:@"ScreenningViewCell" bundle:nil]  forCellWithReuseIdentifier:@"cell"];
    
    
    [self.contentView addSubview:_collectionView];
    layout.delegate = self;
    layout.showDecorationView = YES;
    layout.margin = 10;
    layout.spacePerItem = 20;
    layout.spacePerLine = 10;
    //
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
}

#pragma mark - TaoziLayoutDelegate

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    //    return CGSizeMake(_collectionView.frame.size.width, 38);
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 180);
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _headerPicArray.count;
}

- (CGFloat)tzcollectionLayoutWidth
{
    return _collectionView.frame.size.width;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //    if (section == _showCitiesIndex) {
    return _headerPicArray.count;
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
    
    [cell.picImage sd_setImageWithURL:[NSURL URLWithString:_headerPicArray[indexPath.row]] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.png"]];
    
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
