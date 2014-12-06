//
//  TaoziCollectionLayout.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TaoziCollectionLayout.h"
#import "CityCardReusableView.h"

@interface TaoziCollectionLayout () {
    CGFloat offsetY;
}

@property (nonatomic, strong) NSMutableArray *itemsAttributes;
@property (nonatomic, strong) NSMutableArray *headerViewAttributes;
@property (strong, nonatomic) NSMutableArray *sectionAttributes;

@end

@implementation TaoziCollectionLayout

#pragma mark - UICollectionViewLayout

- (void)prepareLayout
{
    NSInteger sections = [_delegate numberOfSectionsInTZCollectionView:self.collectionView];
    _width = [_delegate tzcollectionLayoutWidth];
    _itemsAttributes = [[NSMutableArray alloc] init];
    _headerViewAttributes = [[NSMutableArray alloc] init];
    _sectionAttributes = [NSMutableArray new];
    offsetY = 0;
    for (int i=0; i<sections; i++) {
        CGFloat offsetX = 10.0;
        NSInteger itemsCountPerSection = [_delegate tzcollectionView:self.collectionView numberOfItemsInSection:i];
       
        NSIndexPath *headerIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];

        CGSize headerSize = [_delegate collectionview:self.collectionView sizeForHeaderView:headerIndexPath];
        
        UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:headerIndexPath];
        headerAttributes.frame = CGRectMake(0, offsetY, _width, headerSize.height);
        [_headerViewAttributes addObject:headerAttributes];
        offsetY += headerSize.height+10;
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        CGFloat heighest = 0;
        for (int j=0; j<itemsCountPerSection; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGSize itemSize = [_delegate collectionView:self.collectionView sizeForItemAtIndexPath:indexPath];
            if (offsetX + itemSize.width > (_width-20)) {
                offsetX = 10;
                offsetY += itemSize.height + 10;
            }
            attributes.frame = CGRectMake(offsetX, offsetY, itemSize.width, itemSize.height);
            offsetX += 10 + itemSize.width;
            
            (heighest < itemSize.height)? (heighest=itemSize.height):(heighest=heighest);
            [tempArray addObject:attributes];
        }
        offsetY += 10+heighest;
        [_itemsAttributes addObject:tempArray];
        
        
        //
        NSInteger lastIndex = [self.collectionView numberOfItemsInSection:i] - 1;
        if (lastIndex < 0)
            continue;
        
        UICollectionViewLayoutAttributes *firstItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        UICollectionViewLayoutAttributes *lastItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:i]];
        
        CGRect frame = CGRectUnion(firstItem.frame, lastItem.frame);
        frame.origin.x -= 10.0;
        frame.origin.y -= 10.0;
        frame.size.width = self.collectionView.frame.size.width;
        frame.size.height += self.sectionInset.top + self.sectionInset.bottom + 20.0;
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"CityCardReusableView" withIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        attributes.zIndex = -1;
        attributes.frame = frame;
        [_sectionAttributes addObject:attributes];
        [self registerClass:[CityCardReusableView class] forDecorationViewOfKind:@"CityCardReusableView"];
//        [self registerNib:[UINib nibWithNibName:@"SectionCard" bundle:[NSBundle mainBundle]] forDecorationViewOfKind:@"SectionCard"];
    }
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return _headerViewAttributes[indexPath.section];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    for (int i=0; i<_itemsAttributes.count; i++) {
        for (int j=0; j<[_itemsAttributes[i] count]; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    for (int i = 0; i<_headerViewAttributes.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        [attributes addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath]];
    }
    for (UICollectionViewLayoutAttributes *attribute in self.sectionAttributes)
    {
        if (!CGRectIntersectsRect(rect, attribute.frame))
            continue;
        
        [attributes addObject:attribute];
    }
    return attributes;
}


-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *retVal = _itemsAttributes[indexPath.section][indexPath.row];
    return retVal;
}

-(CGSize)collectionViewContentSize{
    CGSize retVal = self.collectionView.bounds.size;
    retVal.height = offsetY + 100;
    return retVal;
}

@end
