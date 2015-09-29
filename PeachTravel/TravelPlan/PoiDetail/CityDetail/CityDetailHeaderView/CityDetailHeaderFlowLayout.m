//
//  CityDetailHeaderFlowLayout.m
//  CityDetailHeaderView
//
//  Created by 冯宁 on 15/9/23.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "CityDetailHeaderFlowLayout.h"

@implementation CityDetailHeaderFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSMutableArray* attributes = [NSMutableArray array];
    
    NSInteger itemCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    CGSize itemSize  = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    
    UICollectionViewLayoutAttributes* attrFirst = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    CGFloat margin = ([UIScreen mainScreen].bounds.size.width - itemSize.width * itemCount) / (itemCount + 3);
    
    attrFirst.frame = CGRectMake(margin * 2, 12, itemSize.width, itemSize.height);
    attrFirst.indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    
    [attributes addObject:attrFirst];
//    CGFloat itemWidth = itemSize.width;
//    CGFloat startX = attrFirst.frame.origin.x;
//    CGFloat endX = rect.size.width - 49;
    
//    CGFloat margin = ((endX - startX) - attributes.count * itemWidth) / (attributes.count - 1);
//    self.minimumInteritemSpacing = margin;
    
    for (int i = 1; i < itemCount; i++) {
        UICollectionViewLayoutAttributes* attrCurrent = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        UICollectionViewLayoutAttributes* attrPrevious = attributes[i - 1];
        
        CGFloat startPoint = CGRectGetMaxX(attrPrevious.frame);
        CGFloat endPoint = startPoint + margin;
        
        attrCurrent.frame = (CGRect){{endPoint,12},itemSize};

        [attributes addObject:attrCurrent];


    }
    
    NSLog(@"%@",attributes);
    return attributes;
    
}

@end
