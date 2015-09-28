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
    
    NSArray* attributes = [super layoutAttributesForElementsInRect:rect];
    
    UICollectionViewLayoutAttributes* attrFirst = [attributes firstObject];
//    UICollectionViewLayoutAttributes* attrLast = [attributes lastObject];
    
    CGFloat itemWidth = attrFirst.frame.size.width;
    CGFloat startX = attrFirst.frame.origin.x;
    CGFloat endX = rect.size.width - self.sectionInset.right;
    
    CGFloat margin = ((endX - startX) - attributes.count * itemWidth) / (attributes.count - 1);
    
    for (int i = 1; i < attributes.count; i++) {
        UICollectionViewLayoutAttributes* attrCurrent = attributes[i];
        UICollectionViewLayoutAttributes* attrPrevious = attributes[i - 1];
        
        CGFloat startPoint = CGRectGetMaxX(attrPrevious.frame);
        CGFloat endPoint = startPoint + margin;
        
        attrCurrent.frame = (CGRect){{endPoint,attrCurrent.frame.origin.y},attrCurrent.frame.size};
        
    }
    
    NSLog(@"%@",attributes);
    return attributes;
    
}

@end
