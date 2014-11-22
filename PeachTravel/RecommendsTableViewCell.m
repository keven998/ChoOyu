//
//  RecommendsTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RecommendsTableViewCell.h"
#import "RecommendCollectionViewCell.h"

@implementation RecommendsTableViewCell

static NSString * recommendCollectionReusableIdentifier = @"recommendCollectionCell";

- (void)awakeFromNib {
    _recommendCollectionView.delegate = self;
    _recommendCollectionView.dataSource = self;
    [_recommendCollectionView registerNib:[UINib nibWithNibName:@"RecommendCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:recommendCollectionReusableIdentifier];
}

- (void)setRecommends:(NSArray *)recommends
{
    [_recommendCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return _recommends.count;
    return 10;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RecommendCollectionViewCell *recommendCollectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:recommendCollectionReusableIdentifier forIndexPath:indexPath];
    [recommendCollectionCell.backGroundImage sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:nil];
    recommendCollectionCell.titleLabel.text = @"提拉米苏";
    return recommendCollectionCell;
    
}

@end
