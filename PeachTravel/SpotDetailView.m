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

@interface SpotDetailView ()


@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *detailView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ResizableView *descView;
@property (nonatomic, strong) EDStarRating *ratingView;
@property (nonatomic, strong) UIButton *showMoreDescContentBtn;
@property (nonatomic, strong) UILabel *ticketLabel;

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
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, self.bounds.size.width, self.bounds.size.height-30)];
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
    
    UIView *imageMaskView = [[UIView alloc] initWithFrame:_imageView.bounds];
    imageMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [_imageView addSubview:imageMaskView];
    
    [_scrollView addSubview:_imageView];
    TaoziImage *image = [_spot.images firstObject];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    offsetY += _imageView.bounds.size.height + 15;
    
    
    UIImageView *ticketBkgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, offsetY, _scrollView.bounds.size.width-30, 117)];
    ticketBkgImageView.image = [UIImage imageNamed:@"ticketBkg.png"];
    [_scrollView addSubview:ticketBkgImageView];
     
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
    [_imageView addSubview:viewImageBtn];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-80, _imageView.bounds.size.height-40, 30, 30)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_spot_favorite.png"] forState:UIControlStateNormal];
    [_imageView addSubview:_favoriteBtn];
    
    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-40, _imageView.bounds.size.height-40, 30, 30)];
    [_shareBtn setImage:[UIImage imageNamed:@"ic_spot_share.png"] forState:UIControlStateNormal];
    [_imageView addSubview:_shareBtn];
    
    offsetY += 40;
    
    UILabel *addressTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, offsetY, 100, 15)];
    addressTitle.textColor = APP_THEME_COLOR;
    addressTitle.text = @"地址";
    addressTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
//    [_scrollView addSubview:addressTitle];
    
    offsetY += 15;
    
    
    UIView *btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollView.bounds.size.height-70, _scrollView.bounds.size.width, 57.5)];
    btnBackView.backgroundColor = APP_PAGE_COLOR;
    [_scrollView addSubview:btnBackView];
    
    UIImageView *addressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_spot_address.png"]];
    addressImageView.center = CGPointMake(_scrollView.bounds.size.width/2, _scrollView.bounds.size.height-120);
    [_scrollView addSubview:addressImageView];
    
    UILabel *addressDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _scrollView.bounds.size.height-105, _scrollView.bounds.size.width-20, 40)];
    addressDetailLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    addressDetailLabel.textColor = TEXT_COLOR_TITLE;
    addressDetailLabel.numberOfLines = 2.0;
    addressDetailLabel.text = _spot.address;
    addressDetailLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:addressDetailLabel];
    
    CGFloat spaceWidth = (_scrollView.bounds.size.width-45*4-70)/3;
    
    _spotDescBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, 6.5, 45, 45)];
    [_spotDescBtn setImage:[UIImage imageNamed:@"ic_spot_detail.png"] forState:UIControlStateNormal];
    [btnBackView addSubview:_spotDescBtn];
    
    _trafficGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(35+45+spaceWidth, 6.5, 45, 45)];
    [_trafficGuideBtn setImage:[UIImage imageNamed:@"ic_spot_detail.png"] forState:UIControlStateNormal];
    [btnBackView addSubview:_trafficGuideBtn];
    
    _travelGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(35+45*2+spaceWidth*2, 6.5, 45, 45)];
    [_travelGuideBtn setImage:[UIImage imageNamed:@"ic_spot_detail.png"] forState:UIControlStateNormal];
    [btnBackView addSubview:_travelGuideBtn];
    
    _kendieBtn = [[UIButton alloc] initWithFrame:CGRectMake(35+45*3+spaceWidth*3, 6.5, 45, 45)];
    [_kendieBtn setImage:[UIImage imageNamed:@"ic_spot_detail.png"] forState:UIControlStateNormal];
    [btnBackView addSubview:_kendieBtn];
    
    
}

#pragma mark - IBAction Methods

- (IBAction)showMoreContent:(id)sender
{
    [_descView showMoreContent];
    [UIView animateWithDuration:0.2 animations:^{
        [_headerView setFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height + _descView.resizeHeight)];
        [_showMoreDescContentBtn setFrame:CGRectMake(_showMoreDescContentBtn.frame.origin.x, _showMoreDescContentBtn.frame.origin.y+_descView.resizeHeight, _showMoreDescContentBtn.frame.size.width, _showMoreDescContentBtn.frame.size.height)];
        [_detailView setFrame:CGRectMake(_detailView.frame.origin.x, _detailView.frame.origin.y+_descView.resizeHeight, _detailView.frame.size.width, _detailView.frame.size.height)];
        _showMoreDescContentBtn.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
    }];
    
    [self setContentSize:CGSizeMake(self.contentSize.width, self.contentSize.height+_descView.resizeHeight)];
    [_showMoreDescContentBtn removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_showMoreDescContentBtn addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)hideContent:(id)sender
{
    _descView.numberOfLine = 2;
    [_descView hideContent];
    [UIView animateWithDuration:0.2 animations:^{
        [_headerView setFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height - _descView.resizeHeight)];
        [_showMoreDescContentBtn setFrame:CGRectMake(_showMoreDescContentBtn.frame.origin.x, _showMoreDescContentBtn.frame.origin.y - _descView.resizeHeight, _showMoreDescContentBtn.frame.size.width, _showMoreDescContentBtn.frame.size.height)];
         [_detailView setFrame:CGRectMake(_detailView.frame.origin.x, _detailView.frame.origin.y-_descView.resizeHeight, _detailView.frame.size.width, _detailView.frame.size.height)];
        _showMoreDescContentBtn.transform = CGAffineTransformMakeRotation(360 *M_PI / 180.0);

    }];
    [self setContentSize:CGSizeMake(self.contentSize.width, self.contentSize.height-_descView.resizeHeight)];
    [_showMoreDescContentBtn removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)viewImage:(id)sender
{
    
}



@end
