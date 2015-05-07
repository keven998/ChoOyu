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
//@property (nonatomic, strong) UIButton *phoneButton;

@end

@implementation SpotDetailView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = APP_PAGE_COLOR;
        self.backgroundColor = [UIColor whiteColor];
        _scrollView = [[UIScrollView alloc] init];
//                       With_Frame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _scrollView.frame = self.bounds;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
//        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, _scrollView.bounds.size.height+1000);
        [self addSubview:_scrollView];
        
//        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-64, 0, 64, 40)];
//        [_closeBtn setImage:[UIImage imageNamed:@"ic_dialog_window_close.png"] forState:UIControlStateNormal];
//        _closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        _closeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 11, 5);
//        [self addSubview:_closeBtn];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_scrollView addSubview:_imageView];
    }
    return self;
}

- (void)setSpot:(SpotPoi *)spot
{
    _spot = spot;
    [self setupSubView];

}

- (void)setupSubView{
    CGFloat offsetY = 0;
    
    _imageView.frame = CGRectMake(0, offsetY, _scrollView.bounds.size.width, _scrollView.bounds.size.width/2);
    _imageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _imageView.userInteractionEnabled = YES;
    
    UIView *imageMaskView = [[UIView alloc] initWithFrame:_imageView.bounds];
    imageMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [_imageView addSubview:imageMaskView];
    
    [_scrollView addSubview:_imageView];
    TaoziImage *image = [_spot.images firstObject];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    offsetY += _imageView.bounds.size.height+10;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, offsetY, _imageView.bounds.size.width-50, 30)];
    _titleLabel.textColor = TEXT_COLOR_TITLE;
    _titleLabel.text = _spot.zhName;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:24];
    
    [_scrollView addSubview:_titleLabel];
    
    offsetY += 30;
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake((_imageView.bounds.size.width-65)/2, offsetY, 65, 15)];
//    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray_small.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"ic_star_yellow_small.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.rating = _spot.rating;
    [_scrollView addSubview:_ratingView];
    
    UIButton *viewImageBtn = [[UIButton alloc] initWithFrame:_imageView.frame];
    viewImageBtn.center = CGPointMake(_imageView.bounds.size.width/2, 85);
//    [viewImageBtn setImage:[UIImage imageNamed:@"viewSpotImage.png"] forState:UIControlStateNormal];
    [viewImageBtn addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:viewImageBtn];
    
//    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-100, _imageView.bounds.size.height-45, 55, 45)];
//    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_spot_favorite.png"] forState:UIControlStateNormal];
//    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_spot_favorite_selected.png"] forState:UIControlStateSelected];
//    _favoriteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    _favoriteBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
//    [_imageView addSubview:_favoriteBtn];
//    _favoriteBtn.selected = _spot.isMyFavorite;
//    
//    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-45, _imageView.bounds.size.height-45, 45, 45)];
//    [_shareBtn setImage:[UIImage imageNamed:@"ic_spot_share.png"] forState:UIControlStateNormal];
//    _shareBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 2);
//    [_imageView addSubview:_shareBtn];
    
    offsetY += 50;
    
    _bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-100, offsetY+20, 80, 30)];
    [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xeeeeee)] forState:UIControlStateDisabled];
    _bookBtn.clipsToBounds = YES;
    _bookBtn.layer.cornerRadius = 5;
    [_bookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_bookBtn setTitleColor:UIColorFromRGB(0xd5d5d5) forState:UIControlStateDisabled];
    _bookBtn.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [_bookBtn setTitle:@"预订" forState:UIControlStateNormal];
    _bookBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    [_scrollView addSubview:_bookBtn];
    if ([_spot.bookUrl isBlankString] || !_spot.bookUrl) {
        _bookBtn.enabled = NO;
    }
    CGFloat width = _scrollView.bounds.size.width;
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY-28, width, 1)];
    spaceView.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView];

    
    
    UILabel *destTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY-20, width, 25)];
//    destTitle.backgroundColor = UIColorFromRGB(0xdfdfdf);
    destTitle.text = @"实用信息";
    destTitle.font = [UIFont boldSystemFontOfSize:17];
    destTitle.textColor = TEXT_COLOR_TITLE;
    destTitle.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:destTitle];
    offsetY += 25;
    
//    UILabel *ticketTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY, width, 25)];
//    ticketTitle.backgroundColor = UIColorFromRGB(0xdfdfdf);
//    ticketTitle.text = @"门票";
//    ticketTitle.font = [UIFont systemFontOfSize:11];
//    ticketTitle.textColor = TEXT_COLOR_TITLE_HINT;
//    ticketTitle.textAlignment = NSTextAlignmentCenter;
//    [_scrollView addSubview:ticketTitle];
//
    
    _ticketBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, width, 20)];
//    _ticketBtn.backgroundColor  = [UIColor redColor];
    [_ticketBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_ticketBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateHighlighted];
    _ticketBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_ticketBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
//    [_ticketBtn setTitle:_spot.desc forState:UIControlStateNormal];
//    _ticketBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//    _ticketBtn.titleLabel.numberOfLines = 2;
    _ticketBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    _ticketBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
//    [_ticketBtn setContentEdgeInsets:UIEdgeInsetsMake(20, 20, 10, 20)];
    _ticketBtn.contentEdgeInsets = UIEdgeInsetsMake(0, width/3, 0, 0);
    [_ticketBtn setTitle:_spot.priceDesc forState:UIControlStateNormal];
    [_scrollView addSubview:_ticketBtn];
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 100, _ticketBtn.bounds.size.height)];
    priceLabel.text = @"门票";
    priceLabel.font = [UIFont systemFontOfSize:14];
    priceLabel.textColor = TEXT_COLOR_TITLE;
    [_ticketBtn addSubview:priceLabel];
    UIImageView *ticketImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 3, 18, 18)];
    ticketImageView.image = [UIImage imageNamed:@"ticket"];
    [_ticketBtn addSubview:ticketImageView];
//    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
//    CGRect rect = [_ticketBtn.titleLabel.text boundingRectWithSize:CGSizeMake(width, 2 * _ticketBtn.titleLabel.font.lineHeight)
//                                                           options:NSStringDrawingUsesLineFragmentOrigin
////                                                        attributes:attributes
//                                                           context:nil];
//    _ticketBtn.frame = CGRectMake(0, offsetY, width, rect.size.height + 30);
    offsetY += 35;
    
    UIView *spaceView2 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
    spaceView2.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView2];
    
    NSMutableString *content = [[NSMutableString alloc] init];
    if (_spot.timeCostStr && ![_spot.timeCostStr isBlankString]) {
        [content appendString:[NSString stringWithFormat:@"%@\n", _spot.timeCostStr]];
    }
    [content appendString:[NSString stringWithFormat:@"%@", _spot.openTime]];
    _travelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, width, 65)];
    [_travelBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_travelBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateHighlighted];
    _travelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//    _travelBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//    [_travelBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateNormal];
    
    _travelBtn.titleLabel.numberOfLines = 2;
    [_travelBtn setTitle:_spot.desc forState:UIControlStateNormal];
    [_travelBtn setContentEdgeInsets:UIEdgeInsetsMake(0, width/3, 0, 0)];
    [_travelBtn setTitle:content forState:UIControlStateNormal];
    _travelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_scrollView addSubview:_travelBtn];
    
    NSMutableString *content1 = [[NSMutableString alloc] init];
    if (_spot.timeCostStr && ![_spot.timeCostStr isBlankString]) {
        [content1 appendString:[NSString stringWithFormat:@"建议游玩:\n"]];
    }
    [content1 appendString:[NSString stringWithFormat:@"开放时间:"]];

    UILabel *travelLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 100, _travelBtn.bounds.size.height)];
    travelLabel.numberOfLines = 2;
    travelLabel.font = [UIFont systemFontOfSize:14];
    travelLabel.textColor = TEXT_COLOR_TITLE;
    travelLabel.text = content1;
    [_travelBtn addSubview:travelLabel];
    UIImageView *travelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 23, 18, 18)];
    travelImageView.image = [UIImage imageNamed:@"travel suggest"];
    [_travelBtn addSubview:travelImageView];
    
    
    offsetY += 65;
    UIView *spaceView3 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
    spaceView3.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView3];
    
    
    _phoneButton = [[UIButton alloc]initWithFrame:CGRectMake(0, offsetY, width, 65)];
    [_phoneButton setTitle:_spot.telephone forState:UIControlStateNormal];
    [_phoneButton setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    _phoneButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_phoneButton setContentEdgeInsets:UIEdgeInsetsMake(0, width/3, 0, 0)];
    _phoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [_scrollView addSubview:_phoneButton];
    UILabel *phoneLabel = [[UILabel   alloc]initWithFrame:CGRectMake(50, 0, 100, _travelBtn.bounds.size.height)];
    phoneLabel.font = [UIFont systemFontOfSize:14];
    phoneLabel.textColor = TEXT_COLOR_TITLE;
    phoneLabel.text = @"电话";
    [_phoneButton addSubview:phoneLabel];
    UIImageView *phoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 23, 18, 18)];
    phoneImageView.image = [UIImage imageNamed:@"phone"];
    [_phoneButton addSubview:phoneImageView];

    
    offsetY += 65;
    UIView *spaceView1 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
    spaceView1.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView1];

    
    
    
    _addressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, width, 65)];
    _addressBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_addressBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_addressBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateHighlighted];
    _addressBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _addressBtn.titleLabel.numberOfLines = 2;
    _addressBtn.layer.cornerRadius = 4.0;
    _addressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _addressBtn.contentEdgeInsets = UIEdgeInsetsMake(0, width/3, 0, 0);
//    [_addressBtn setContentEdgeInsets:UIEdgeInsetsMake(2, 10, 0, 10)];
//    _addressBtn.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
//    _addressBtn.layer.borderWidth = 0.5;
    _addressBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if ([_spot.address isBlankString] || !_spot.address) {
        [_addressBtn setTitle:_spot.zhName forState:UIControlStateNormal];
    } else {
        [_addressBtn setTitle:_spot.address forState:UIControlStateNormal];
    }
    [_scrollView addSubview:_addressBtn];
    UIImageView *addressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 23, 18, 18)];
    addressImageView.image = [UIImage imageNamed:@"map"];
    [_addressBtn addSubview:addressImageView];
    
    UILabel *address = [[UILabel   alloc]initWithFrame:CGRectMake(50, 0, 100, _travelBtn.bounds.size.height)];
    address.font = [UIFont systemFontOfSize:14];
    address.textColor = TEXT_COLOR_TITLE;
    address.text = @"地图";
    [_addressBtn addSubview:address];
    
    offsetY += 65;

    
    UIView *spaceView4 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
    spaceView4.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView4];
    
    
    
    _descDetailBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, width, 65)];
    [_descDetailBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_descDetailBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateHighlighted];
    _descDetailBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _descDetailBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_descDetailBtn setTitle:_spot.desc forState:UIControlStateNormal];
    _descDetailBtn.titleLabel.numberOfLines = 3;
    [_descDetailBtn setContentEdgeInsets:UIEdgeInsetsMake(0, width/3, 0, 0)];
    _descDetailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_scrollView addSubview:_descDetailBtn];
    
    
    UILabel *introduction = [[UILabel   alloc]initWithFrame:CGRectMake(50, 0, 100, _travelBtn.bounds.size.height)];
    introduction.font = [UIFont systemFontOfSize:14];
    introduction.textColor = TEXT_COLOR_TITLE;
    introduction.text = @"景点简介";
    [_descDetailBtn addSubview:introduction];
    UIImageView *descImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 23, 18, 18)];
    descImageView.image = [UIImage imageNamed:@"spot introduction"];
    [_descDetailBtn addSubview:descImageView];
    
    offsetY += 65;
    
    UIView *spaceView5 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
    spaceView5.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView5];
    
//    UILabel *timeTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY, width, 25)];
//    timeTitle.backgroundColor = UIColorFromRGB(0xdfdfdf);
//    timeTitle.text = @"游玩";
//    timeTitle.font = [UIFont systemFontOfSize:11];
//    timeTitle.textColor = TEXT_COLOR_TITLE_HINT;
//    timeTitle.textAlignment = NSTextAlignmentCenter;
//    [_scrollView addSubview:timeTitle];
    
//    offsetY += 25;
//    
//    
//    
//    
//
//    
//    
//    offsetY += _ticketBtn.frame.size.height;
   
    
//    _bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-100, offsetY, 80, 30)];
//    [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
//    [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xeeeeee)] forState:UIControlStateDisabled];
//    _bookBtn.clipsToBounds = YES;
//    _bookBtn.layer.cornerRadius = 5;
//    [_bookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_bookBtn setTitleColor:UIColorFromRGB(0xd5d5d5) forState:UIControlStateDisabled];
//    _bookBtn.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
//    [_bookBtn setTitle:@"预订" forState:UIControlStateNormal];
//    _bookBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    [_scrollView addSubview:_bookBtn];
//    if ([_spot.bookUrl isBlankString] || !_spot.bookUrl) {
//        _bookBtn.enabled = NO;
//    }
    
//    offsetY += 50;
    
    
    UIView *btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, _scrollView.bounds.size.width, 75)];
    btnBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_scrollView addSubview:btnBackView];
    
    CGFloat spaceWidth = (btnBackView.bounds.size.width-48*3-70)/3;
    
    _kendieBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [_kendieBtn setBackgroundImage:[UIImage imageNamed:@"ic_little notes"] forState:UIControlStateNormal];
    [_kendieBtn setBackgroundImage:[UIImage imageNamed:@"btn_spot_info_disable.png"] forState:UIControlStateDisabled];
//    [_kendieBtn setTitle:@"小贴士" forState:UIControlStateNormal];
    _kendieBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    _kendieBtn.titleLabel.numberOfLines = 2;
    [_kendieBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
//    _kendieBtn.backgroundColor = [UIColor blackColor];
    _kendieBtn.center = CGPointMake(CGRectGetWidth(btnBackView.frame)/2, 32);
    [_kendieBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_kendieBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [_kendieBtn setTitleColor:UIColorFromRGB(0xdddddd) forState:UIControlStateDisabled];
    [btnBackView addSubview:_kendieBtn];
    
    _travelGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [_travelGuideBtn setBackgroundImage:[UIImage imageNamed:@"ic_spots experience"] forState:UIControlStateNormal];
    [_travelGuideBtn setBackgroundImage:[UIImage imageNamed:@"ic_spots experience"] forState:UIControlStateDisabled];
    _travelGuideBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    _travelGuideBtn.titleLabel.numberOfLines = 2;
    [_travelGuideBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_travelGuideBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [_travelGuideBtn setTitleColor:UIColorFromRGB(0xdddddd) forState:UIControlStateDisabled];

    _travelGuideBtn.center = CGPointMake(_kendieBtn.center.x - spaceWidth - 48, 32);
    [btnBackView addSubview:_travelGuideBtn];
    
    _trafficGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [_trafficGuideBtn setBackgroundImage:[UIImage imageNamed:@"ic_travel"] forState:UIControlStateNormal];
    [_trafficGuideBtn setBackgroundImage:[UIImage imageNamed:@"btn_spot_info_disable.png"] forState:UIControlStateDisabled];
//    [_trafficGuideBtn setTitle:@"交通" forState:UIControlStateNormal];
    _trafficGuideBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    _trafficGuideBtn.titleLabel.numberOfLines = 2;
    [_trafficGuideBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_trafficGuideBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [_trafficGuideBtn setTitleColor:UIColorFromRGB(0xdddddd) forState:UIControlStateDisabled];
    _trafficGuideBtn.center = CGPointMake(_kendieBtn.center.x + spaceWidth + 48, 32);
    [btnBackView addSubview:_trafficGuideBtn];
    offsetY += 50;
    
    UILabel *guideLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 68, 15)];
    guideLabel.center = CGPointMake(_kendieBtn.center.x - spaceWidth - 48, offsetY+25);
    if (_trafficGuideBtn.enabled ) {
        guideLabel.textColor = TEXT_COLOR_TITLE;
    }
    else{
        guideLabel.textColor = UIColorFromRGB(0xdddddd);
    }
    guideLabel.text = @"景点攻略";
    guideLabel.textAlignment = NSTextAlignmentCenter;
    guideLabel.font = [UIFont systemFontOfSize:13];
    [_scrollView addSubview:guideLabel];
    
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 48, 15)];
    tipsLabel.center = CGPointMake(CGRectGetWidth(btnBackView.frame)/2, offsetY + 25);
    tipsLabel.textColor = _kendieBtn.enabled?TEXT_COLOR_TITLE:UIColorFromRGB(0xdddddd);
    tipsLabel.text = @"小贴士";
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont systemFontOfSize:13];
    [_scrollView addSubview:tipsLabel];
    
    UILabel *trafficLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 48, 15)];
    trafficLabel.center = CGPointMake(_kendieBtn.center.x + spaceWidth + 48, offsetY + 25);
    trafficLabel.textColor = _trafficGuideBtn.enabled?TEXT_COLOR_TITLE:UIColorFromRGB(0xdddddd);
    trafficLabel.text = @"交通";
    trafficLabel.textAlignment = NSTextAlignmentCenter;
    trafficLabel.font = [UIFont systemFontOfSize:13];
    [_scrollView addSubview:trafficLabel];
    
    
    offsetY +=50;
    UIView *spaceView6 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
    spaceView6.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView6];
    
    

    
    UILabel *commentTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 14)];
    commentTitle.text = @"网友点评";
    commentTitle.textAlignment = NSTextAlignmentCenter;
    commentTitle.font = [UIFont systemFontOfSize:16.0];
    commentTitle.textColor = TEXT_COLOR_TITLE;
    commentTitle.center = CGPointMake(_scrollView.bounds.size.width/2, offsetY+20);

    [_scrollView addSubview:commentTitle];
    
    
    UIButton *moreCommentBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-80, offsetY, 80, 40)];
    [moreCommentBtn setTitle:@"更多点评>>" forState:UIControlStateNormal];
    [moreCommentBtn addTarget:self action:@selector(showMoreComments:) forControlEvents:UIControlEventTouchUpInside];
    [moreCommentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [moreCommentBtn setTitleColor:APP_SUB_THEME_COLOR forState:UIControlStateNormal];
    [moreCommentBtn setTitleColor:APP_SUB_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    moreCommentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_scrollView addSubview:moreCommentBtn];
    
    offsetY += 40;
    
    if (_spot.comments.count >= 1) {
        
        UIImageView *dotImageViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(10, offsetY-10, 20, 17)];
        dotImageViewLeft.image = [UIImage imageNamed:@"ic_quotation_l.png"];
        dotImageViewLeft.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:dotImageViewLeft];
        
        CommentDetail *comment = [_spot.comments objectAtIndex:0];
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 40)];
        commentLabel.numberOfLines = 3.0;
        commentLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        commentLabel.font = [UIFont systemFontOfSize:12];
        commentLabel.text = comment.commentDetails;
        [_scrollView addSubview:commentLabel];
        offsetY += 40;
        UILabel *commentSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 15)];
        commentSubLabel.textColor = TEXT_COLOR_TITLE_PH;
        commentSubLabel.font = [UIFont systemFontOfSize:10];
        commentSubLabel.textAlignment = NSTextAlignmentRight;
        NSString *s = [NSString stringWithFormat:@"%@  %@", comment.nickName, comment.commentTime];
        commentSubLabel.text = s;
        [_scrollView addSubview:commentSubLabel];
        offsetY += 15;
    }
    offsetY += 10;
    if (_spot.comments.count >= 2) {
        CommentDetail *comment = [_spot.comments objectAtIndex:1];
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 40)];
        commentLabel.numberOfLines = 3.0;
        commentLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        commentLabel.font = [UIFont systemFontOfSize:12];
        commentLabel.text = comment.commentDetails;
        [_scrollView addSubview:commentLabel];
        offsetY += 40;
        UILabel *commentSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 15)];
        commentSubLabel.textColor = TEXT_COLOR_TITLE_PH;
        commentSubLabel.font = [UIFont systemFontOfSize:10];
        commentSubLabel.textAlignment = NSTextAlignmentRight;
        NSString *s = [NSString stringWithFormat:@"%@  %@", comment.nickName, comment.commentTime];
        commentSubLabel.text = s;
        [_scrollView addSubview:commentSubLabel];
        offsetY += 15;
    }
    
    if (_spot.comments.count > 0) {
        offsetY += 10;
        UIImageView *dotImageViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-30, offsetY-20, 20, 17)];
        dotImageViewRight.image = [UIImage imageNamed:@"ic_quotation_r.png"];
        dotImageViewRight.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:dotImageViewRight];
    }
    
    
    
    offsetY += 50;

    
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, offsetY+75)];
    
}

- (void)showMoreComments:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"全部点评";
    webCtl.urlStr = _spot.moreCommentsUrl;
    [_rootCtl.navigationController pushViewController:webCtl animated:YES];
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
