//
//  TaoziCollectionLayout.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaoziLayoutDelegate <NSObject>

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath;

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView;

- (CGFloat)tzcollectionLayoutWidth;

@end

@interface TaoziCollectionLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) id <TaoziLayoutDelegate> delegate;

@property (nonatomic) CGFloat width;

@end
