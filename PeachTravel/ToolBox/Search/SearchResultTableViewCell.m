//
//  SearchResultTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SearchResultTableViewCell.h"
#import "FrendListTagCell.h"
#import "TaoziCollectionLayout.h"

@interface SearchResultTableViewCell () <TaoziLayoutDelegate,UICollectionViewDataSource>

@end

@implementation SearchResultTableViewCell

- (void)awakeFromNib
{
    self.headerImageView.layer.cornerRadius = 2.0;
    self.headerImageView.clipsToBounds = YES;
    
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _sendBtn.layer.cornerRadius = 2.0;
    _sendBtn.backgroundColor = APP_THEME_COLOR;
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(15.0, CGRectGetHeight(self.frame) - 0.6, CGRectGetWidth(self.frame), 0.6)];
    divider.backgroundColor = COLOR_LINE;
    divider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:divider];
    
    /** @property (nonatomic,strong) EDImage *starHighlightedImage;
     @property (nonatomic,strong) EDImage *starImage;
     @property (nonatomic) NSInteger maxRating;
     @property (nonatomic) float rating; */
    _ratingView.starImage = [UIImage imageNamed:@"poi_bottom_star_default"];
    
    // 设置评分的图片
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"poi_bottom_star_selected"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 2;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.userInteractionEnabled = NO;
    
    [self setUpFlowLayout];
    
    self.tagsCollectionView.dataSource = self;
    [self.tagsCollectionView registerClass:[FrendListTagCell class] forCellWithReuseIdentifier:@"cell"];
    UIView* view = [[UIView alloc] init];
    self.tagsCollectionView.backgroundView = view;
    self.tagsCollectionView.backgroundColor = [UIColor clearColor];
    self.tagsCollectionView.scrollEnabled = NO;
    self.tagsCollectionView.userInteractionEnabled = NO;
    
}

- (void)setIsCanSend:(BOOL)isCanSend
{
    _isCanSend = isCanSend;
    if (_isCanSend) {
        _sendBtn.hidden = NO;
    } else {
        _sendBtn.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - dataSource相关
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  self.tagsArray.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FrendListTagCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.tagString = (NSString*)self.tagsArray[indexPath.item];
    cell.titleFontSize = 12;
    return cell;
}

- (void)setTagsArray:(NSArray *)tagsArray{
    _tagsArray = tagsArray;
    NSLog(@"------  tagsArray %@",tagsArray);
    [self.tagsCollectionView reloadData];
}

#pragma mark - flowLayout相关
- (void)setUpFlowLayout{
    self.flowLayout.delegate = self;
    self.flowLayout.showDecorationView = NO;
    self.flowLayout.spacePerItem = 6;
    self.flowLayout.spacePerLine = 0;
    self.flowLayout.margin = 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [self.tagsArray objectAtIndex:indexPath.row];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.0]}];
    return CGSizeMake(size.width + 15, 14);
}

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    return CGSizeZero;
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tagsArray.count;
}

- (CGFloat)tzcollectionLayoutWidth
{
    return self.bounds.size.width-20;
}

@end
