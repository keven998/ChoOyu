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
        self.backgroundColor = APP_PAGE_COLOR;
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
    
    CGFloat galleryHeight = width * 1038/1242;
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
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake(14, offsetY+18, 115, 21)];
    _ratingView.starImage = [UIImage imageNamed:@"poi_bottom_star_default"];
    
    // 设置评分的图片
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"poi_bottom_star_selected"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 2;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.rating = _spot.rating;
    [self addSubview:_ratingView];
    
    UIButton *tagBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-131, offsetY + 8.5, 116, 40)];
    
    NSString * tagTitle = nil;
    if (self.spot.style.count == 0)
    {
        switch (self.spot.poiType) {
            case kSpotPoi:
                tagTitle = @"景点";
                break;
            case kHotelPoi:
                tagTitle = @"宾馆";
                break;
            case kRestaurantPoi:
                tagTitle = @"餐厅";
                break;
            case kShoppingPoi:
                tagTitle = @"购物";
                break;
            default:
                break;
        }
    }else{
        NSLog(@"%@",[_spot.style firstObject]);
        tagTitle = [_spot.style firstObject];
    }

    [tagBtn setTitle:tagTitle forState:UIControlStateNormal];
    [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tagBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [tagBtn setBackgroundImage:[[UIImage imageNamed:@"poi_bg_sort"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    tagBtn.userInteractionEnabled = NO;
    [self addSubview:tagBtn];
    
    UIButton *rankBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 6, 22, 28)];
    rankBtn.userInteractionEnabled = NO;
    [rankBtn setBackgroundImage:[UIImage imageNamed:@"poi_bg_sort_flower.png"] forState:UIControlStateNormal];
    rankBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rankBtn setTitleEdgeInsets:UIEdgeInsetsMake(-2, 1, 2, 0)];
    [rankBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (_spot.rank == 0 || _spot.rank > 500) {
        [rankBtn setTitle:@"N" forState:UIControlStateNormal];
        rankBtn.titleLabel.font = [UIFont systemFontOfSize:9.0];
    } else  {
        [rankBtn setTitle:[NSString stringWithFormat:@"%d", _spot.rank] forState:UIControlStateNormal];
        if (_spot.rank < 10) {
            rankBtn.titleLabel.font = [UIFont systemFontOfSize:9.0];
        } else if (_spot.rank >= 10 && _spot.rank < 100) {
            rankBtn.titleLabel.font = [UIFont systemFontOfSize:8.0];
        } else {
            rankBtn.titleLabel.font = [UIFont systemFontOfSize:6.0];
        }
    }
    [tagBtn addSubview:rankBtn];
    
    offsetY += 57;
    
    NSString *descStr = _spot.desc;
    if (descStr != nil && ([descStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0)) {
        _poiSummary = [[UIButton alloc]initWithFrame:CGRectMake(0, offsetY, width, 114)];
        [_poiSummary setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_poiSummary setBackgroundImage:[ConvertMethods createImageWithColor:APP_PAGE_COLOR] forState:UIControlStateHighlighted];
        [self addSubview:_poiSummary];
        _poisDesc = _poiSummary;
        [_poiSummary setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
        _poiSummary.titleLabel.numberOfLines = 3;
        _poiSummary.titleLabel.font = [UIFont systemFontOfSize:16];
        [_poiSummary setTitleEdgeInsets:UIEdgeInsetsMake(10, 18, 10, 18)];
        CGRect minRect = [descStr boundingRectWithSize:CGSizeMake(width-36, 22)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                               context:nil];
        CGRect maxRect = [descStr boundingRectWithSize:CGSizeMake(width-36, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                               context:nil];
        NSInteger totalLine = ceilf(maxRect.size.height / minRect.size.height);
        NSInteger ccount = descStr.length;
        NSInteger count = ccount * 3/totalLine;
        if (count < ccount) {
            NSString *truncateStr = [descStr substringWithRange:NSMakeRange(0, count - 3)];
            NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
            ps.lineSpacing = 4.0;
            NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:ps};
            truncateStr = [NSString stringWithFormat:@"%@... ", truncateStr];
            NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:truncateStr attributes:attribs];
            NSAttributedString *more1 = [[NSAttributedString alloc] initWithString:@"全文" attributes:@{NSForegroundColorAttributeName : APP_THEME_COLOR, NSFontAttributeName: [UIFont systemFontOfSize:16]}];
            [attrstr appendAttributedString:more1];
            [_poiSummary setAttributedTitle:attrstr forState:UIControlStateNormal];
        } else {
            NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
            ps.lineSpacing = 4.0;
            NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:ps};
            NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:descStr attributes:attribs];
            [_poiSummary setAttributedTitle:attrstr forState:UIControlStateNormal];
        }
        
        offsetY = CGRectGetMaxY(_poiSummary.frame);
        
        UIView *spaceView5 = [[UIView alloc] initWithFrame:CGRectMake(18, offsetY-0.5, self.bounds.size.width - 18, 0.5)];
        spaceView5.backgroundColor = COLOR_LINE;
        [self addSubview:spaceView5];
    }
    
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
