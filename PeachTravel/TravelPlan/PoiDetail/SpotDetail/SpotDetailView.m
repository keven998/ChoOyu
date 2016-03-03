//
//  SpotDetailView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotDetailView.h"
#import "ResizableView.h"
#import "EDStarRating.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "CommentDetail.h"
#import "SuperWebViewController.h"
#import "SwipeView.h"
#import "CommentTableViewCell.h"

@interface SpotDetailView ()<SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *detailView;
@property (nonatomic, strong) EDStarRating *ratingView;
@property (nonatomic, strong) UIButton *travelMonthBtn;
@property (nonatomic, strong) UIButton *openTimeBtn;
@property (nonatomic, strong) UIButton *timeCostBtn;
@property (nonatomic, strong) UIButton *readAllBtn;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *poisDesc;

@end

@implementation SpotDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setSpot:(SuperPoi *)spot
{
    _spot = spot;
    [self setupSubView];
}

- (void)setupSubView{
    CGFloat offsetY = 0;
    CGFloat width = CGRectGetWidth(self.bounds);
    
    CGFloat galleryHeight = width/2;
    SwipeView *swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, offsetY, width, galleryHeight)];
    swipeView.dataSource = self;
    swipeView.delegate = self;
    swipeView.bounces = NO;
    swipeView.backgroundColor = COLOR_DISABLE;
    swipeView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    swipeView.pagingEnabled = YES;
    swipeView.itemsPerPage = 1;
    [self addSubview:swipeView];
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20)];
    _pageControl.center = CGPointMake(width/2, CGRectGetMaxY(swipeView.frame)-20);
    _pageControl.numberOfPages = _spot.images.count;
    _pageControl.currentPageIndicatorTintColor = APP_THEME_COLOR;
    _pageControl.pageIndicatorTintColor = COLOR_DISABLE;
    _pageControl.hidesForSinglePage = YES;
    [self addSubview:_pageControl];
    
    offsetY += galleryHeight;
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake(12, offsetY+12, 90, 25)];
    _ratingView.starImage = [UIImage imageNamed:@"icon_rating_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"icon_rating_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 1;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.userInteractionEnabled = NO;
    _ratingView.rating = _spot.rating;
    [self addSubview:_ratingView];
    
    if (_spot.poiType != kSpotPoi) {
        NSString *tagTitle = [_spot.style firstObject];
        if (tagTitle) {
            NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                      };
            NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:tagTitle attributes:attribs];
            CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-32, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            
            UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-rect.size.width-45, offsetY + 14, rect.size.width+30, 20)];
            tagLabel.backgroundColor = APP_THEME_COLOR;
            tagLabel.layer.cornerRadius = 4.0;
            tagLabel.clipsToBounds = YES;
            tagLabel.textColor = [UIColor whiteColor];
            tagLabel.font = [UIFont systemFontOfSize:12];
            tagLabel.textAlignment = NSTextAlignmentCenter;
            tagLabel.text = tagTitle;
            [self addSubview:tagLabel];
        }
    } else {
        if (![((SpotPoi *)_spot).timeCostStr isBlankString] && ((SpotPoi *)_spot).timeCostStr) {
            NSString *timeStr = [NSString stringWithFormat:@"建议游玩%@", ((SpotPoi *)_spot).timeCostStr];
            UILabel *timeCostLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-158, offsetY + 18, 150, 20)];
            timeCostLabel.textColor = COLOR_TEXT_II;
            timeCostLabel.font = [UIFont systemFontOfSize:12];
            timeCostLabel.textAlignment = NSTextAlignmentRight;
            timeCostLabel.text = timeStr;
            [self addSubview:timeCostLabel];
        }
    } 
    
    offsetY += 45;
    
    UILabel *moneyCostLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, width-24, 20)];
    moneyCostLabel.textColor = COLOR_TEXT_II;
    moneyCostLabel.font = [UIFont systemFontOfSize:14.0];
    
    NSString *priceDesc;
    if (!_spot.priceDesc || [_spot.priceDesc isEqual:[NSNull null]]) {
        priceDesc = @"未知";
    } else {
        priceDesc = _spot.priceDesc;
    }
    NSString *moneyCost = [NSString stringWithFormat:@"费用:  %@", priceDesc];
    NSMutableAttributedString *attrMoneyCost = [[NSMutableAttributedString alloc] initWithString:moneyCost];
    [attrMoneyCost addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0], NSForegroundColorAttributeName: COLOR_TEXT_I} range:NSMakeRange(0, 3)];
    
    moneyCostLabel.attributedText = attrMoneyCost;
    [self addSubview:moneyCostLabel];
    
    offsetY += 30;
    
    UILabel *openTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, width-24, 20)];
    openTimeLabel.textColor = COLOR_TEXT_II;
    openTimeLabel.font = [UIFont systemFontOfSize:14.0];
    
    NSString *tempOpenTime;
    if (!_spot.openTime || [_spot.openTime isEqual:[NSNull null]]) {
        tempOpenTime = @"全天";
    } else {
        tempOpenTime = _spot.openTime;
    }
    NSString *openTime = [NSString stringWithFormat:@"开放时间:  %@", tempOpenTime];
    NSMutableAttributedString *attrOpenTime = [[NSMutableAttributedString alloc] initWithString:openTime];
    [attrOpenTime addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0], NSForegroundColorAttributeName: COLOR_TEXT_I} range:NSMakeRange(0, 5)];
    openTimeLabel.attributedText = attrOpenTime;
    [self addSubview:openTimeLabel];
    
    offsetY += 30;
    
    self.frame = CGRectMake(0, 0, width, offsetY + 10);
}

#pragma mark - SwipeViewDataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return _spot.images.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UIImageView *imageView = (UIImageView *)view;
    if (imageView == nil)
    {
        imageView = [[UIImageView alloc] initWithFrame:swipeView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = APP_BORDER_COLOR;
    }
    
    TaoziImage *image = [_spot.images objectAtIndex:index];
    [imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    [_pageControl setCurrentPage:index];
    return imageView;
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    NSInteger count = _spot.images.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        TaoziImage *image = [_spot.images objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = image.imageUrl; // 图片路径
        photo.srcImageView = (UIImageView *)[swipeView itemViewAtIndex:index]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

@end
