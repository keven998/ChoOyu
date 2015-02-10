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

@interface SpotDetailView ()


@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *detailView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) EDStarRating *ratingView;
@property (nonatomic, strong) UIButton *travelMonthBtn;
@property (nonatomic, strong) UIButton *openTimeBtn;
@property (nonatomic, strong) UIButton *timeCostBtn;


@end

@implementation SpotDetailView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = APP_PAGE_COLOR;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, self.bounds.size.width, self.bounds.size.height-35)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, _scrollView.bounds.size.height+1);
        [self addSubview:_scrollView];
        
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-40, 0, 40, 40)];
        [_closeBtn setImage:[UIImage imageNamed:@"ic_dialog_window_close.png"] forState:UIControlStateNormal];
        [_closeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
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
//    _imageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
//    _imageView.layer.cornerRadius = 2.0;
//    _imageView.layer.borderWidth = 0.5;
    _imageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _imageView.userInteractionEnabled = YES;
    
    UIView *imageMaskView = [[UIView alloc] initWithFrame:_imageView.bounds];
    imageMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [_imageView addSubview:imageMaskView];
    
    [_scrollView addSubview:_imageView];
    TaoziImage *image = [_spot.images firstObject];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 15, _imageView.bounds.size.width-50, 30)];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = _spot.zhName;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:24];
    
    [_imageView addSubview:_titleLabel];
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake((_imageView.bounds.size.width-100)/2, 50, 100, 15)];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"ic_star_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.rating = _spot.rating;
    [_imageView addSubview:_ratingView];
    
    UIButton *viewImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    viewImageBtn.center = CGPointMake(_imageView.bounds.size.width/2, 90);
    [viewImageBtn setImage:[UIImage imageNamed:@"viewSpotImage.png"] forState:UIControlStateNormal];
    [viewImageBtn addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:viewImageBtn];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-70, _imageView.bounds.size.height-35, 30, 30)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_spot_favorite.png"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_spot_favorite_selected.png"] forState:UIControlStateSelected];
    [_imageView addSubview:_favoriteBtn];
    
    if (_spot.isMyFavorite) {
        _favoriteBtn.selected = YES;
    }
    
    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-40, _imageView.bounds.size.height-35, 30, 30)];
    [_shareBtn setImage:[UIImage imageNamed:@"ic_spot_share.png"] forState:UIControlStateNormal];
    [_imageView addSubview:_shareBtn];
    
    offsetY += _imageView.bounds.size.height;
    
    CGFloat width = _scrollView.bounds.size.width;
    
    UILabel *destTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY, width, 25)];
    destTitle.backgroundColor = UIColorFromRGB(0xdfdfdf);
    destTitle.text = @"景点介绍";
    destTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
    destTitle.textColor = TEXT_COLOR_TITLE_HINT;
    destTitle.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:destTitle];
    offsetY += 25;
    
    _descDetailBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, width, 65)];
    [_descDetailBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    _descDetailBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13];
    _descDetailBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_descDetailBtn setTitle:_spot.desc forState:UIControlStateNormal];
    _descDetailBtn.titleLabel.numberOfLines = 2;
    [_descDetailBtn setContentEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    _descDetailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_scrollView addSubview:_descDetailBtn];
    offsetY += 65;
    
    UILabel *timeTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY, width, 25)];
    timeTitle.backgroundColor = UIColorFromRGB(0xdfdfdf);
    timeTitle.text = @"游玩";
    timeTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
    timeTitle.textColor = TEXT_COLOR_TITLE_HINT;
    timeTitle.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:timeTitle];
    
    offsetY += 25;
    
    NSMutableString *content = [[NSMutableString alloc] init];
    if (_spot.timeCostStr && ![_spot.timeCostStr isBlankString]) {
        [content appendString:[NSString stringWithFormat:@"建议游玩 %@\n", _spot.timeCostStr]];
    }
    [content appendString:[NSString stringWithFormat:@"开放时间 %@", _spot.openTime]];
    _travelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, width, 65)];
    [_travelBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    _travelBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
    _travelBtn.titleLabel.numberOfLines = 2;
    _travelBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_travelBtn setTitle:_spot.desc forState:UIControlStateNormal];
    [_travelBtn setContentEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    [_travelBtn setTitle:content forState:UIControlStateNormal];
    _travelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_scrollView addSubview:_travelBtn];
    offsetY += 65;
    
    UILabel *ticketTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY, width, 25)];
    ticketTitle.backgroundColor = UIColorFromRGB(0xdfdfdf);
    ticketTitle.text = @"门票";
    ticketTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
    ticketTitle.textColor = TEXT_COLOR_TITLE_HINT;
    ticketTitle.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:ticketTitle];
    offsetY += 25;

    _ticketBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, width, 65)];
    [_ticketBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    _ticketBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
    _ticketBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_ticketBtn setTitle:_spot.desc forState:UIControlStateNormal];
    _ticketBtn.titleLabel.numberOfLines = 2;
    _ticketBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _ticketBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    [_ticketBtn setContentEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    [_ticketBtn setTitle:_spot.priceDesc forState:UIControlStateNormal];
    [_scrollView addSubview:_ticketBtn];
    offsetY += 75;
   
    UIButton *bookBtn = [[UIButton alloc] initWithFrame:CGRectMake((width-75)/2, offsetY, 75, 25)];
    [bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    bookBtn.clipsToBounds = YES;
    bookBtn.layer.cornerRadius = 12.5;
    [bookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bookBtn.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [bookBtn setTitle:@"在线预订" forState:UIControlStateNormal];
    [bookBtn addTarget:self action:@selector(book:) forControlEvents:UIControlEventTouchUpInside];
    bookBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];
    [_scrollView addSubview:bookBtn];
    
    offsetY += 50;
    
    UIImageView *addressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, offsetY, 12, 18)];
    addressImageView.image = [UIImage imageNamed:@"ic_spot_map.png"];
    [_scrollView addSubview:addressImageView];
    
    _addressBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, offsetY, width-60, 45)];
    _addressBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];
    [_addressBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [_addressBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
    _addressBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _addressBtn.titleLabel.numberOfLines = 2;
    _addressBtn.layer.cornerRadius = 4.0;
    _addressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_addressBtn setContentEdgeInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    _addressBtn.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
    _addressBtn.layer.borderWidth = 0.5;
    _addressBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    if ([_spot.address isBlankString] || !_spot.address) {
        [_addressBtn setTitle:_spot.zhName forState:UIControlStateNormal];
    } else {
        [_addressBtn setTitle:_spot.address forState:UIControlStateNormal];
    }
    [_scrollView addSubview:_addressBtn];
    
    offsetY += 12 + 32 + 15;
    
    UIView *btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, _scrollView.bounds.size.width, 75)];
    btnBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    btnBackView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:btnBackView];
    
    CGFloat spaceWidth = (btnBackView.bounds.size.width-48*3-70)/3;
    
    _kendieBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [_kendieBtn setBackgroundImage:[UIImage imageNamed:@"btn_spot_info_enable.png"] forState:UIControlStateNormal];
    [_kendieBtn setBackgroundImage:[UIImage imageNamed:@"btn_spot_info_disable.png"] forState:UIControlStateDisabled];
    [_kendieBtn setTitle:@"小\n贴士" forState:UIControlStateNormal];
    _kendieBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _kendieBtn.titleLabel.numberOfLines = 2;
    [_kendieBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
    _kendieBtn.center = CGPointMake(CGRectGetWidth(btnBackView.frame)/2, 32);
    [_kendieBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_kendieBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [_kendieBtn setTitleColor:UIColorFromRGB(0xdddddd) forState:UIControlStateDisabled];
    [btnBackView addSubview:_kendieBtn];
    
    _travelGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [_travelGuideBtn setBackgroundImage:[UIImage imageNamed:@"btn_spot_info_enable.png"] forState:UIControlStateNormal];
    [_travelGuideBtn setBackgroundImage:[UIImage imageNamed:@"btn_spot_info_disable.png"] forState:UIControlStateDisabled];
    [_travelGuideBtn setTitle:@"景点\n体验" forState:UIControlStateNormal];
    _travelGuideBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _travelGuideBtn.titleLabel.numberOfLines = 2;
    [_travelGuideBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_travelGuideBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [_travelGuideBtn setTitleColor:UIColorFromRGB(0xdddddd) forState:UIControlStateDisabled];
    _travelGuideBtn.center = CGPointMake(_kendieBtn.center.x - spaceWidth - 48, 32);
    [btnBackView addSubview:_travelGuideBtn];
    
    _trafficGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [_trafficGuideBtn setBackgroundImage:[UIImage imageNamed:@"btn_spot_info_enable.png"] forState:UIControlStateNormal];
    [_trafficGuideBtn setBackgroundImage:[UIImage imageNamed:@"btn_spot_info_disable.png"] forState:UIControlStateDisabled];
    [_trafficGuideBtn setTitle:@"交通" forState:UIControlStateNormal];
    _trafficGuideBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_trafficGuideBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_trafficGuideBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [_trafficGuideBtn setTitleColor:UIColorFromRGB(0xdddddd) forState:UIControlStateDisabled];
    _trafficGuideBtn.center = CGPointMake(_kendieBtn.center.x + spaceWidth + 48, 32);
    [btnBackView addSubview:_trafficGuideBtn];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, offsetY+60)];
    
}

#pragma mark - IBAction Methods

- (IBAction)summary:(id)sender {
    
}

- (IBAction)book:(id)sender {
    
}

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
