//
//  GoodsRecommendHeaderView.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsRecommendHeaderView.h"
#import "AutoSlideScrollView.h"
#import "GoodsRecommendCollectionViewCell.h"

@interface GoodsRecommendHeaderView()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UIButton *searchBtn;
@property (strong, nonatomic) AutoSlideScrollView *galleryView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *slideDataSource;
@property (strong, nonatomic) NSArray *specialDataSource;

@end

@implementation GoodsRecommendHeaderView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _galleryView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 210) animationDuration:5];
        _galleryView.scrollView.showsHorizontalScrollIndicator = NO;
        __weak GoodsRecommendHeaderView *weakSelf = self;
        _galleryView.TapActionBlock = ^(NSInteger index) {
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectItem:)]) {
                [weakSelf.delegate didSelectItem:[[weakSelf.slideDataSource objectAtIndex:index] objectForKey:@"link"]];
            }
        };
        
        _searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, frame.size.width-60, 27)];
       
        [_searchBtn setBackgroundImage:[[UIImage imageNamed:@"icon_goods_search_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 40, 2, 20)] forState:UIControlStateNormal];
        [self addSubview:_galleryView];
//        [self addSubview:_searchBtn];
        UICollectionViewFlowLayout*layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 15;
        layout.itemSize = CGSizeMake(100, 100);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 210, frame.size.width, 125) collectionViewLayout:layout];
        [self addSubview:_collectionView];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 12, 0, 12);
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = APP_PAGE_COLOR;
        [_collectionView registerNib:[UINib nibWithNibName:@"GoodsRecommendCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"goodsRecommendCollectionViewCell"];
       
    }
    return self;
}

- (void)setRecommendData:(NSArray *)recommendData
{
    _recommendData = recommendData;
    self.slideDataSource = [[_recommendData firstObject] objectForKey:@"columns"];
    self.specialDataSource = [[_recommendData lastObject] objectForKey:@"columns"];
}

- (void)setSlideDataSource:(NSArray *)slideDataSource
{
    _slideDataSource = slideDataSource;
    __weak GoodsRecommendHeaderView *weakSelf = self;
    self.galleryView.totalPagesCount = ^NSInteger() {
        return weakSelf.slideDataSource.count;
    };
    self.galleryView.fetchContentViewAtIndex = ^UIView*(NSInteger pageIndex) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, weakSelf.frame.size.width, 210)];
        TaoziImage *image = [[TaoziImage alloc] initWithJson:[[[weakSelf.slideDataSource objectAtIndex:pageIndex] objectForKey:@"images"] firstObject]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
        return imageView;
    };
}

- (void)setSpecialDataSource:(NSArray *)specialDataSource
{
    _specialDataSource = specialDataSource;
    [_collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_specialDataSource count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsRecommendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"goodsRecommendCollectionViewCell" forIndexPath:indexPath];
    TaoziImage *image = [[TaoziImage alloc] initWithJson:[[[_specialDataSource objectAtIndex:indexPath.row] objectForKey:@"images"] firstObject]];
    [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(didSelectItem:)]) {
        NSDictionary *dic = [_specialDataSource objectAtIndex:indexPath.row];
        [self.delegate didSelectItem:[dic objectForKey:@"link"]];
    }
}

@end
