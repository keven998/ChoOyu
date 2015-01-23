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
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, _scrollView.bounds.size.height+1);
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
    CGFloat offsetY = 20;
    
    _imageView.frame = CGRectMake(10, 15, 100, 100);
    _imageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _imageView.layer.cornerRadius = 2.0;
    _imageView.layer.borderWidth = 0.5;
    _imageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    [_scrollView addSubview:_imageView];
    TaoziImage *image = [_spot.images firstObject];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x+_imageView.frame.size.width+10, offsetY, self.bounds.size.width-(_imageView.frame.origin.x+_imageView.frame.size.width+20)-20, 20)];
    _titleLabel.textColor = APP_THEME_COLOR;
    _titleLabel.text = _spot.zhName;
    _titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0];
    [_scrollView addSubview:_titleLabel];
    
    offsetY += 25;
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, offsetY, 40, 15)];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.rating = _spot.rating;
    [_scrollView addSubview:_ratingView];
    
    offsetY += 40;
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, offsetY, 45, 25)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_favorite.png"] forState:UIControlStateNormal];
    [_scrollView addSubview:_favoriteBtn];
    
    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(_favoriteBtn.frame.size.width+_favoriteBtn.frame.origin.x, offsetY, 45, 25)];
    [_shareBtn setImage:[UIImage imageNamed:@"ic_share.png"] forState:UIControlStateNormal];
    [_scrollView addSubview:_shareBtn];
    
    offsetY += 40;
    
    UILabel *addressTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, offsetY, 100, 15)];
    addressTitle.textColor = APP_THEME_COLOR;
    addressTitle.text = @"地址";
    addressTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    [_scrollView addSubview:addressTitle];
    
    offsetY += 15;
    
    UILabel *addressDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, offsetY, self.bounds.size.width-60, 30)];
    addressDetailLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    addressDetailLabel.textColor = TEXT_COLOR_TITLE;
    addressDetailLabel.numberOfLines = 2.0;
    addressDetailLabel.text = _spot.address;
    [_scrollView addSubview:addressDetailLabel];
    
    _addressBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-50, offsetY-5, 40, 40)];
    [_addressBtn setImage:[UIImage imageNamed:@"ic_poidetail_map.png"] forState:UIControlStateNormal];
    [_scrollView addSubview:_addressBtn];
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
