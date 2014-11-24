//
//  RecommendsTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RecommendsTableViewCell.h"
#import "RecommendCollectionViewCell.h"
#import "RecommendDetail.h"

@implementation RecommendsTableViewCell

static NSString * recommendCollectionReusableIdentifier = @"recommendCollectionCell";

- (void)awakeFromNib {
    _recommendCollectionView.delegate = self;
    _recommendCollectionView.dataSource = self;
    [_recommendCollectionView registerNib:[UINib nibWithNibName:@"RecommendCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:recommendCollectionReusableIdentifier];
}

- (void)setRecommends:(NSArray *)recommends
{
    _recommends = recommends;
    [_recommendCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _recommends.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RecommendDetail *recommendDetail = [_recommends objectAtIndex:indexPath.row];
    TaoziImage *image = [recommendDetail.images firstObject];
    RecommendCollectionViewCell *recommendCollectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:recommendCollectionReusableIdentifier forIndexPath:indexPath];
    [recommendCollectionCell.backGroundImage sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    recommendCollectionCell.titleLabel.text = recommendDetail.title;
    return recommendCollectionCell;
    
}

@end
