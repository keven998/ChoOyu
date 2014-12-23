//
//  TaoziCollectionLayout.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaoziLayoutDelegate <NSObject>

/**
 *  每个 collectioncell 的尺寸
 *
 *  @param collectionView
 *  @param indexPath
 *
 *  @return
 */
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  每个分组 header 的尺寸
 *
 *  @param collectionView
 *  @param indexPath
 *
 *  @return
 */
- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath;

/**
 *  每个分组有多少个 cell
 *
 *  @param collectionView
 *  @param section
 *
 *  @return
 */
- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

/**
 *  共有多少个分组
 *
 *  @param collectionView
 *
 *  @return
 */
- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView;

/**
 *  整个 collection 的宽度
 *
 *  @return
 */
- (CGFloat)tzcollectionLayoutWidth;

@end

@interface TaoziCollectionLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) id <TaoziLayoutDelegate> delegate;

/**
 *  是否显示每个组的背景
 */
@property (nonatomic) BOOL showDecorationView;

@property (nonatomic) CGFloat width;

/**
 *  最坐标 cell 距离边线的距离
 */
@property (nonatomic) CGFloat margin;

@end
