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
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) EDStarRating *ratingView;
@property (nonatomic, strong) UIButton *travelMonthBtn;
@property (nonatomic, strong) UIButton *openTimeBtn;
@property (nonatomic, strong) UIButton *timeCostBtn;
@property (nonatomic, strong) UIButton *readAllBtn;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UILabel *poisDesc;

@end

@implementation SpotDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = APP_PAGE_COLOR;
        _backgroundView = [[UIView alloc] init];
        _backgroundView.frame = self.bounds;
        [self addSubview:_backgroundView];

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
    
    SwipeView *swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, offsetY, CGRectGetWidth(self.bounds), 350)];
    swipeView.dataSource = self;
    swipeView.delegate = self;
    swipeView.bounces = NO;
    swipeView.backgroundColor = APP_BORDER_COLOR;
    swipeView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    swipeView.pagingEnabled = YES;
    swipeView.itemsPerPage = 1;
    [_backgroundView addSubview:swipeView];
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20)];
    _pageControl.center = CGPointMake(CGRectGetWidth(self.bounds)/2, 350-20);
    _pageControl.numberOfPages = _spot.images.count;
    _pageControl.currentPageIndicatorTintColor = APP_THEME_COLOR;
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.hidesForSinglePage = YES;
    [_backgroundView addSubview:_pageControl];
    
    offsetY += swipeView.frame.size.height;
    
    UIButton *tagBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-132, offsetY + 10, 116, 40)];
    [tagBtn setTitle:@"高等学府" forState:UIControlStateNormal];
    [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tagBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [tagBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [tagBtn setBackgroundImage:[UIImage imageNamed:@"poi_bg_sort"] forState:UIControlStateNormal];
    tagBtn.userInteractionEnabled = NO;
    [_backgroundView addSubview:tagBtn];
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake(15, offsetY+18, 110, 22)];
    _ratingView.starImage = [UIImage imageNamed:@"poi_bottom_star_default"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"poi_bottom_star_selected"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.rating = _spot.rating;
    [_backgroundView addSubview:_ratingView];
    
    offsetY += 60;
    
    CGFloat width = SCREEN_WIDTH;
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, offsetY, width, 342/3)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.userInteractionEnabled = YES;
    [_backgroundView addSubview:bgView];
    
    _poisDesc = [[UILabel alloc] initWithFrame:CGRectMake(18, offsetY, width-36, 342/3)];
    _poisDesc.textColor = COLOR_TEXT_I;
    _poisDesc.numberOfLines = 3;
    _poisDesc.userInteractionEnabled = YES;
    NSString *string = _spot.desc;
    CGRect minRect = [string boundingRectWithSize:CGSizeMake(width-36, 18)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                          context:nil];
    CGRect maxRect = [string boundingRectWithSize:CGSizeMake(width-36, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                          context:nil];
    NSInteger totalLine = ceilf(maxRect.size.height / minRect.size.height);
    NSInteger ccount = string.length;
    NSInteger count = ccount * 3/totalLine;
    NSString *truncateStr = [[NSString alloc]init];
    if (string.length <= count - 3) {
        truncateStr = string ;
    } else {
        truncateStr = [string substringWithRange:NSMakeRange(0, count - 3)];
    }
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 4.0;
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:ps};
    truncateStr = [NSString stringWithFormat:@"%@... ", truncateStr];
    NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:truncateStr attributes:attribs];
    NSAttributedString *more1 = [[NSAttributedString alloc] initWithString:@"更多" attributes:@{NSForegroundColorAttributeName : APP_THEME_COLOR_HIGHLIGHT, NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    [attrstr appendAttributedString:more1];
    _poisDesc.attributedText = attrstr;
    _poisDesc.backgroundColor = [UIColor whiteColor];
    [_backgroundView addSubview:_poisDesc];
    
    
    offsetY += 342/3;
        
    UIView *spaceView5 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, _backgroundView.bounds.size.width, 1)];
    spaceView5.backgroundColor = APP_DIVIDER_COLOR;
    [_backgroundView addSubview:spaceView5];
    
    offsetY += 10;
    _backgroundView.frame = CGRectMake(0, 0, SCREEN_WIDTH, offsetY);
    
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
