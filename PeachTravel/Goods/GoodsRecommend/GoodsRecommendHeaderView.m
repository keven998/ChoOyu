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


@end


@implementation GoodsRecommendHeaderView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _galleryView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 210)];
        _galleryView.backgroundColor = [UIColor redColor];
        _galleryView.scrollView.showsHorizontalScrollIndicator = NO;
        
        _searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, frame.size.width-60, 27)];
        self.galleryView.totalPagesCount = ^NSInteger() {
            return 4;
        };
        self.galleryView.fetchContentViewAtIndex = ^UIView*(NSInteger pageIndex) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 210)];
             [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://images.taozilvxing.com/28c2d1ef35c12100e99fecddb63c436a?imageView2/2/w/1200"] placeholderImage:nil];
            return imageView;
        };
        [_searchBtn setBackgroundImage:[[UIImage imageNamed:@"icon_goods_search_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 40, 2, 20)] forState:UIControlStateNormal];
        [self addSubview:_galleryView];
//        [self addSubview:_searchBtn];
        UICollectionViewFlowLayout*layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 15;
        layout.itemSize = CGSizeMake(85, 85);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 210, frame.size.width, 110) collectionViewLayout:layout];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsRecommendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"goodsRecommendCollectionViewCell" forIndexPath:indexPath];
    return cell;
}


@end
