//
//  SpotDetailView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotDetailView.h"
#import "ResizableView.h"
#import "TZButton.h"
#import "EDStarRating.h"
#import "MJPhotoBrowser/MJPhoto.h"
#import "MJPhotoBrowser.h"

@interface SpotDetailView ()


@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *detailView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) EDStarRating *ratingView;

@property (nonatomic, strong) UIButton *spotDescBtn;
@property (nonatomic, strong) UIButton *travelBtn;
@property (nonatomic, strong) UIButton *travelMonthBtn;
@property (nonatomic, strong) UIButton *openTimeBtn;
@property (nonatomic, strong) UIButton *timeCostBtn;


@end

@implementation SpotDetailView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, self.bounds.size.width, self.bounds.size.height-35)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, _scrollView.bounds.size.height+1);
        _scrollView.scrollEnabled = NO;
        [self addSubview:_scrollView];
        
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-40, 0, 40, 40)];
        [_closeBtn setImage:[UIImage imageNamed:@"ic_close.png"] forState:UIControlStateNormal];
        [self addSubview:_closeBtn];
        
        _imageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_imageView];
    }
    return self;
}

- (void)setSpot:(SpotPoi *)spot
{
    _spot = spot;
    [self setupSubView];
}

- (void)setupSubView
{
    CGFloat offsetY = 0;
    
    _imageView.frame = CGRectMake(0, offsetY, _scrollView.bounds.size.width, _scrollView.bounds.size.width/2);
    _imageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _imageView.layer.cornerRadius = 2.0;
    _imageView.layer.borderWidth = 0.5;
    _imageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _imageView.userInteractionEnabled = YES;
    
    UIView *imageMaskView = [[UIView alloc] initWithFrame:_imageView.bounds];
    imageMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [_imageView addSubview:imageMaskView];
    
    [_scrollView addSubview:_imageView];
    TaoziImage *image = [_spot.images firstObject];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, _imageView.bounds.size.width-20, 30)];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = _spot.zhName;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:30.];
    
    [_imageView addSubview:_titleLabel];
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake((_imageView.bounds.size.width-60)/2, 60, 60, 15)];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.rating = _spot.rating;
    [_imageView addSubview:_ratingView];
    
    UIButton *viewImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    viewImageBtn.center = CGPointMake(_imageView.bounds.size.width/2, 110);
    [viewImageBtn setImage:[UIImage imageNamed:@"viewSpotImage.png"] forState:UIControlStateNormal];
    [viewImageBtn addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:viewImageBtn];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-80, _imageView.bounds.size.height-40, 30, 30)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_spot_favorite.png"] forState:UIControlStateNormal];
    [_imageView addSubview:_favoriteBtn];
    
    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-40, _imageView.bounds.size.height-40, 30, 30)];
    [_shareBtn setImage:[UIImage imageNamed:@"ic_spot_share.png"] forState:UIControlStateNormal];
    [_imageView addSubview:_shareBtn];
    
    offsetY += _imageView.bounds.size.height + 15;
    
    UIImageView *ticketBkgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, offsetY, _scrollView.bounds.size.width-30, 120)];
    ticketBkgImageView.image = [UIImage imageNamed:@"ticketBkg.png"];
    [_scrollView addSubview:ticketBkgImageView];
    
    UIButton *openTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, 5, ticketBkgImageView.bounds.size.width-70, 35)];
    openTimeBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:10.0];
    
    NSMutableString *str = [@"" mutableCopy];
    if (_spot.timeCostStr && ![_spot.timeCostStr isBlankString]) {
        [str appendString:[NSString stringWithFormat:@"建议游玩:%@, ", _spot.timeCostStr]];
    }
    [str appendString:_spot.openTime];
    [openTimeBtn setTitle:str forState:UIControlStateNormal];
    openTimeBtn.titleLabel.numberOfLines = 3;
    openTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    openTimeBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [openTimeBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    openTimeBtn.clipsToBounds = YES;
    [ticketBkgImageView addSubview:openTimeBtn];

    UIButton *ticketBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, 50, ticketBkgImageView.bounds.size.width-70, 35)];
    ticketBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:10.0];
    [ticketBtn setTitle:_spot.priceDesc forState:UIControlStateNormal];
    [ticketBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    ticketBtn.titleLabel.numberOfLines = 3;
    ticketBtn.clipsToBounds = YES;
    ticketBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    ticketBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [ticketBkgImageView addSubview:ticketBtn];
    
    UIButton *bookBtn = [[UIButton alloc] initWithFrame:CGRectMake((ticketBkgImageView.bounds.size.width-75)/2, 95, 75, 15)];
    bookBtn.backgroundColor = APP_THEME_COLOR;
    bookBtn.layer.cornerRadius = 7.5;
    [bookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bookBtn setTitle:@"在线预订" forState:UIControlStateNormal];
    [ticketBkgImageView addSubview:bookBtn];
    bookBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:10.0];
    
    UIView *btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollView.bounds.size.height-70, _scrollView.bounds.size.width, 57.5)];
    btnBackView.backgroundColor = APP_PAGE_COLOR;
    [_scrollView addSubview:btnBackView];
    
    UIImageView *addressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_spot_address.png"]];
    addressImageView.center = CGPointMake(_scrollView.bounds.size.width/2, _scrollView.bounds.size.height-120);
    [_scrollView addSubview:addressImageView];
    
    UIButton *addressDetailBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, _scrollView.bounds.size.height-105, _scrollView.bounds.size.width-20, 40)];
    addressDetailBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    [addressDetailBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    addressDetailBtn.titleLabel.numberOfLines = 2.0;
    [addressDetailBtn setTitle:_spot.address forState:UIControlStateNormal];
    addressDetailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    addressDetailBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_scrollView addSubview:addressDetailBtn];
    
    CGFloat spaceWidth = (_scrollView.bounds.size.width-45*4-70)/3;
    
    _spotDescBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, 6.5, 45, 45)];
    [_spotDescBtn setImage:[UIImage imageNamed:@"ic_spot_detail.png"] forState:UIControlStateNormal];
    [_spotDescBtn setTitle:@"简介" forState:UIControlStateNormal];
    [btnBackView addSubview:_spotDescBtn];
    
    _trafficGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(35+45+spaceWidth, 6.5, 45, 45)];
    [_trafficGuideBtn setImage:[UIImage imageNamed:@"ic_spot_detail.png"] forState:UIControlStateNormal];
    [_trafficGuideBtn setTitle:@"亮点\n体验" forState:UIControlStateNormal];
    [btnBackView addSubview:_trafficGuideBtn];
    
    _travelGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(35+45*2+spaceWidth*2, 6.5, 45, 45)];
    [_travelGuideBtn setImage:[UIImage imageNamed:@"ic_spot_detail.png"] forState:UIControlStateNormal];
    [_travelGuideBtn setTitle:@"实用\n信息" forState:UIControlStateNormal];
    [btnBackView addSubview:_travelGuideBtn];
    
    _kendieBtn = [[UIButton alloc] initWithFrame:CGRectMake(35+45*3+spaceWidth*3, 6.5, 45, 45)];
    [_kendieBtn setImage:[UIImage imageNamed:@"ic_spot_detail.png"] forState:UIControlStateNormal];
    [_kendieBtn setTitle:@"交通" forState:UIControlStateNormal];
    [btnBackView addSubview:_kendieBtn];
    
    
}

#pragma mark - IBAction Methods


- (IBAction)viewImage:(id)sender
{
    if (_spot.images.count==0) {
        return;
    }
    NSInteger count = _spot.images.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        TaoziImage *image = [_spot.images objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:image.imageUrl]; // 图片路径
        photo.srcImageView = _imageView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}



@end
