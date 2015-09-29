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
    
    attrFirst.frame = CGRectMake(49, 12, attrFirst.frame.size.width, attrFirst.frame.size.height);
    
    CGFloat itemWidth = attrFirst.frame.size.width;
    CGFloat startX = attrFirst.frame.origin.x;
    CGFloat endX = rect.size.width - 49;
    
    CGFloat margin = ((endX - startX) - attributes.count * itemWidth) / (attributes.count - 1);
//    self.minimumInteritemSpacing = margin;
    
    for (int i = 1; i < attributes.count; i++) {
        UICollectionViewLayoutAttributes* attrCurrent = attributes[i];
        UICollectionViewLayoutAttributes* attrPrevious = attributes[i - 1];
        
        CGFloat startPoint = CGRectGetMaxX(attrPrevious.frame);
        CGFloat endPoint = startPoint + margin;
        
        attrCurrent.frame = (CGRect){{endPoint,12},attrCurrent.frame.size};

    }
    
    NSLog(@"%@",attributes);
    return attributes;
    
}

@end
