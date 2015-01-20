//
//  SpotDetailView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotDetailView.h"
#import "ResizableView.h"
#import "CycleScrollView.h"
#import "TZButton.h"
#import "NSTimer+Addition.h"

@interface SpotDetailView ()

@property (nonatomic, strong) CycleScrollView *galleryPageView;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *detailView;

@property (nonatomic, strong) UIButton *imagePageIndicator;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) ResizableView *descView;
@property (nonatomic, strong) UIButton *showMoreDescContentBtn;
@property (nonatomic, strong) UIButton *ticketBtn;
@property (nonatomic, strong) UIButton *ticketDescBtn;
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
        self.backgroundColor = APP_PAGE_COLOR;
    }
    return self;
}

- (void)dealloc
{
    [_galleryPageView stopTimer];
}

- (void)setSpot:(SpotPoi *)spot
{
    _spot = spot;
    [self setupSubView];
}

- (void)setupSubView
{
    CGFloat oy = 0;
    CGFloat width = self.frame.size.width;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(11, 10, width-22, 260)];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.layer.cornerRadius = 2.0;
    _headerView.clipsToBounds = YES;
    
    NSInteger count = _spot.images.count;
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < count; i++)
    {
        [images addObject:[NSNull null]];
    }
    _imageViews = images;
    
    _galleryPageView = [[CycleScrollView alloc]initWithFrame:CGRectMake(0, oy, width-22, 167.5) animationDuration:0];
    
    _galleryPageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _galleryPageView.layer.borderWidth = 0.5;
    _galleryPageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    
    __weak typeof(SpotDetailView *)weakSelf = self;
    
    _galleryPageView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return (UIView *)[weakSelf loadScrollViewWithPage:pageIndex];
    };
    
    _galleryPageView.totalPagesCount = ^NSInteger(void){
        return weakSelf.spot.images.count;
    };
    
    _galleryPageView.TapActionBlock = ^(NSInteger pageIndex){
    };
    
    [_headerView addSubview:_galleryPageView];
    
    _imagePageIndicator = [[UIButton alloc] initWithFrame:CGRectMake(_headerView.frame.size.width-53.5, _headerView.frame.size.height-33, 47.5, 23)];
    _imagePageIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_imagePageIndicator setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _imagePageIndicator.userInteractionEnabled = NO;
    _imagePageIndicator.layer.cornerRadius = 1.0;
    [_imagePageIndicator setTitle:[NSString stringWithFormat:@"1/%ld", (unsigned long)_spot.images.count] forState:UIControlStateNormal];
//    [_headerView addSubview:_imagePageIndicator];

    oy += 175;
    
    _titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy, width-90, 30)];
    [_titleBtn setTitle:_spot.zhName forState:UIControlStateNormal];
    [_titleBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_titleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [_titleBtn setImage:[UIImage imageNamed:@"ic_spot.png"] forState:UIControlStateNormal];
    [_titleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    _titleBtn.clipsToBounds = YES;
    _titleBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_titleBtn];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-85, oy, 60, 30)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_unFavorite.png"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_Favorite.png"] forState:UIControlStateHighlighted];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_Favorite.png"] forState:UIControlStateSelected];
    _favoriteBtn.selected = _spot.isMyFavorite;
    [_headerView addSubview:_favoriteBtn];
    
    oy += 35;
    
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(10, oy, width-44, 30) andNumberOfLine:2];
    _descView.contentFont = [UIFont systemFontOfSize:12.0];
    _descView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _descView.content = _spot.desc;

    [_headerView addSubview:_descView];
    
    oy += 35;
    
    if (_descView.maxNumberOfLine > 2) {
        [_descView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        _showMoreDescContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-50, oy, 20, 10)];
        [_showMoreDescContentBtn setImage:[UIImage imageNamed:@"cell_accessory_pink_down.png"] forState:UIControlStateNormal];
        [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_showMoreDescContentBtn];
    }
    
    oy += 20;
    
    CGFloat doy = 0;
    
    _ticketBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width-22, 35)];
    [_ticketBtn setTitle:@"门票" forState:UIControlStateNormal];
    [_ticketBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_ticketBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_ticketBtn setImage:[UIImage imageNamed:@"ic_ticket.png"] forState:UIControlStateNormal];
    _ticketBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _ticketBtn.backgroundColor = [UIColor whiteColor];
    [_ticketBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    [_ticketBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    _ticketBtn.userInteractionEnabled = NO;
    _titleBtn.layer.cornerRadius = 2.0;
    
    doy += 35;
    oy += 35;
    
    _ticketDescBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width-22, 0)];
    _ticketDescBtn.titleLabel.numberOfLines = 0;
    CGSize labelSize = [_spot.priceDesc boundingRectWithSize:CGSizeMake(_ticketDescBtn.bounds.size.width-70, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{
                                                                 NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                                 }
                                                        context:nil].size;
    
    CGFloat height = labelSize.height+40;
    CGFloat ticketHeight = height < 45 ? 45:height;
    
    _ticketDescBtn.frame = CGRectMake(0, doy, width-22, ticketHeight);
    [_ticketDescBtn setTitle:_spot.priceDesc forState:UIControlStateNormal];
    [_ticketDescBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [_ticketDescBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_ticketDescBtn setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    _ticketDescBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    _ticketDescBtn.userInteractionEnabled = NO;
    _ticketDescBtn.layer.cornerRadius = 2.0;
    [_ticketDescBtn setTitleEdgeInsets:UIEdgeInsetsMake(10, 35, 10, 35)];
    _ticketDescBtn.backgroundColor = [UIColor whiteColor];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, doy, width-22, 0.8)];
    spaceView.backgroundColor = APP_PAGE_COLOR;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    leftView.layer.cornerRadius = 10.0;
    leftView.backgroundColor = APP_PAGE_COLOR;
    leftView.center = CGPointMake(0, doy);
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    rightView.layer.cornerRadius = 10.0;
    rightView.backgroundColor = APP_PAGE_COLOR;
    rightView.center = CGPointMake(width-22, doy);
    
    doy += ticketHeight + 10;
    oy += ticketHeight + 10;
    
    _travelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width-22, 35)];
    [_travelBtn setTitle:@"游玩" forState:UIControlStateNormal];
    [_travelBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_travelBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_travelBtn setImage:[UIImage imageNamed:@"ic_travel.png"] forState:UIControlStateNormal];
    _travelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [_travelBtn setBackgroundColor:[UIColor whiteColor]];
    [_travelBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    _travelBtn.userInteractionEnabled = NO;
    _travelBtn.layer.cornerRadius = 2.0;
    [_travelBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    [_travelBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    doy += 45;
    oy += 45;
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:5];

    if (![_spot.travelMonth isBlankString]) {
        _travelMonthBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, doy, width-42, 0)];
        _travelMonthBtn.titleLabel.numberOfLines = 0;
        CGSize labelSize = [_spot.travelMonth boundingRectWithSize:CGSizeMake(_travelMonthBtn.bounds.size.width-80, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{
                                                                  NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                                  } context:nil].size;
        
        CGFloat height = labelSize.height+20;
        _travelMonthBtn.layer.cornerRadius = 4.0;
        [_travelMonthBtn setTitle:_spot.travelMonth forState:UIControlStateNormal];
        _travelMonthBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _travelMonthBtn.layer.borderWidth = 0.5;
        
        _travelMonthBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 70, 0, 10);
        _travelMonthBtn.frame = CGRectMake(_travelMonthBtn.frame.origin.x, _travelMonthBtn.frame.origin.y, _travelMonthBtn.frame.size.width, height);
        [_travelMonthBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        _travelMonthBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [_travelMonthBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        
        UIButton *subTitle = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, _travelMonthBtn.frame.size.height)];
        [subTitle setTitle:@"最佳月份" forState:UIControlStateNormal];
        [subTitle setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
        subTitle.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [_travelMonthBtn addSubview:subTitle];
        subTitle.userInteractionEnabled = NO;
        
        oy += height+10;
        doy += height+10;
    }
    if (![_spot.openTime isBlankString]) {
        _openTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, doy, width-42, 0)];
        _openTimeBtn.titleLabel.numberOfLines = 0;
        CGSize labelSize = [_spot.openTime boundingRectWithSize:CGSizeMake(_openTimeBtn.bounds.size.width-80, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{
                                                      NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                      } context:nil].size;
    
        CGFloat height = labelSize.height+20;

        _openTimeBtn.layer.cornerRadius = 4.0;
        [_openTimeBtn setTitle:_spot.openTime forState:UIControlStateNormal];
        _openTimeBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _openTimeBtn.layer.borderWidth = 0.5;
        _openTimeBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [_openTimeBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        
        _openTimeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 70, 0, 10);
        _openTimeBtn.frame = CGRectMake(_openTimeBtn.frame.origin.x, _openTimeBtn.frame.origin.y, _openTimeBtn.frame.size.width, height);
        [_openTimeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        UIButton *subTitle = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, _openTimeBtn.frame.size.height)];
        [subTitle setTitle:@"开放时间" forState:UIControlStateNormal];
        [subTitle setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
        subTitle.titleLabel.font = [UIFont systemFontOfSize:11.0];
        subTitle.userInteractionEnabled = NO;
        [_openTimeBtn addSubview:subTitle];

        oy += height+10;
        doy += height+10;
    }
    if (![_spot.timeCostStr isBlankString]) {
        _timeCostBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, doy, width-42, 0)];
        _timeCostBtn.titleLabel.numberOfLines = 0;
        CGSize labelSize = [_spot.timeCostStr boundingRectWithSize:CGSizeMake(_timeCostBtn.bounds.size.width-80, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{
                                                                  NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                                  } context:nil].size;
        CGFloat height = labelSize.height+20;
        _timeCostBtn.layer.cornerRadius = 4.0;
        [_timeCostBtn setTitle:_spot.timeCostStr forState:UIControlStateNormal];
        _timeCostBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [_timeCostBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];

        _timeCostBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _timeCostBtn.layer.borderWidth = 0.5;
        _timeCostBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 70, 0, 10);
        _timeCostBtn.frame = CGRectMake(_timeCostBtn.frame.origin.x, _timeCostBtn.frame.origin.y, _timeCostBtn.frame.size.width, height);
        [_timeCostBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        UIButton *subTitle = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, _timeCostBtn.frame.size.height)];
        [subTitle setTitle:@"参考游玩" forState:UIControlStateNormal];
        [subTitle setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
        subTitle.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [_timeCostBtn addSubview:subTitle];
        subTitle.userInteractionEnabled = NO;

        oy += height+10;
        doy += height+10;
    }
    
    _addressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width-22, 0)];
    _addressBtn.titleLabel.numberOfLines = 0;
    CGSize addrLabelSize = [_spot.address boundingRectWithSize:CGSizeMake(_addressBtn.bounds.size.width, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{
                                                                 NSFontAttributeName : [UIFont systemFontOfSize:12.0],
                                                                 } context:nil].size;
    
    CGFloat addressHeight = (addrLabelSize.height+20) < 57.5 ? 57.5 : (addrLabelSize.height+20);
    _addressBtn.frame = CGRectMake(0, doy, width-22, addressHeight);
    [_addressBtn setTitle:_spot.address forState:UIControlStateNormal];
    _addressBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
//    _addressBtn.backgroundColor = [UIColor whiteColor];
    [_addressBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    _addressBtn.layer.cornerRadius = 2.0;
    _addressBtn.clipsToBounds = YES;
    _addressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_addressBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 30)];
    [_addressBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    [_addressBtn setImage:[UIImage imageNamed:@"ic_location.png"] forState:UIControlStateNormal];
    [_addressBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    
    UIImageView *indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(_addressBtn.frame.size.width-17, (_addressBtn.frame.size.height-12)/2, 6, 12)];
    indicatorView.image = [UIImage imageNamed:@"cell_accessory_pink"];
    [_addressBtn addSubview:indicatorView];
    
    oy += addressHeight + 20;
    doy += addressHeight + 20;

    CGFloat space = (width - 80 - 60*3)/3;
    CGFloat ox = 40;
    
    BOOL hasAdd = NO;

    if (![_spot.guideUrl isBlankString]) {
        _travelGuideBtn = [[TZButton alloc] initWithFrame:CGRectMake(ox, doy, 60, 60)];
        [_travelGuideBtn setImage:[UIImage imageNamed:@"travel_guide_unselected.png"] forState:UIControlStateNormal];
        [_travelGuideBtn setImage:[UIImage imageNamed:@"travel_guide_selected.png"] forState:UIControlStateHighlighted];
        [_travelGuideBtn setTitle:@"游玩指南" forState:UIControlStateNormal];
        [_travelGuideBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_travelGuideBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
        _travelGuideBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        
        ox += space+60;
        hasAdd = YES;
    }
    
    if (![_spot.tipsUrl isBlankString]) {
        _kendieBtn = [[TZButton alloc] initWithFrame:CGRectMake(ox, doy, 60, 60)];
        [_kendieBtn setImage:[UIImage imageNamed:@"kengdie_guide_unselected.png"] forState:UIControlStateNormal];
        [_kendieBtn setImage:[UIImage imageNamed:@"kengdie_guide_selected.png"] forState:UIControlStateHighlighted];
        
        [_kendieBtn setTitle:@"Tips" forState:UIControlStateNormal];
        [_kendieBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_kendieBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
        _kendieBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];

        ox += space+60;
        hasAdd = YES;
    }
    
    if (![_spot.trafficInfoUrl isBlankString]) {
        _trafficGuideBtn = [[TZButton alloc] initWithFrame:CGRectMake(ox, doy, 60, 60)];
        [_trafficGuideBtn setImage:[UIImage imageNamed:@"traffic_guide_unselected.png"] forState:UIControlStateNormal];
        [_trafficGuideBtn setImage:[UIImage imageNamed:@"traffic_guide_selected.png"] forState:UIControlStateHighlighted];
        
        [_trafficGuideBtn setTitle:@"交通" forState:UIControlStateNormal];
        [_trafficGuideBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_trafficGuideBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
        _trafficGuideBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];

        hasAdd = YES;
    }
    
    if (hasAdd) {
        oy += 100;
        doy += 100;
    }
   
    
    _detailView = [[UIView alloc] initWithFrame:CGRectMake(11, _headerView.frame.origin.y+_headerView.frame.size.height+10, width-22, doy+10)];
    _detailView.backgroundColor = [UIColor clearColor];
    [_detailView addSubview:_ticketBtn];
    [_detailView addSubview:_ticketDescBtn];
    [_detailView addSubview:spaceView];
    [_detailView addSubview:leftView];
    [_detailView addSubview:rightView];

    [_detailView addSubview:_travelBtn];
    [_detailView addSubview:_travelMonthBtn];
    [_detailView addSubview:_openTimeBtn];
    [_detailView addSubview:_timeCostBtn];
    [_detailView addSubview:_addressBtn];
    [_detailView addSubview:_travelGuideBtn];
    [_detailView addSubview:_kendieBtn];
    [_detailView addSubview:_trafficGuideBtn];
//    [_detailView addSubview:_travelGuideLabel];
//    [_detailView addSubview:_kengdieLabel];
//    [_detailView addSubview:_trafficGuideLabel];

    [self addSubview:_detailView];
    
    
    [self setContentSize:CGSizeMake(self.frame.size.width, oy+110)];
    [self addSubview:_headerView];
    
}

- (UIImageView *)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= _spot.images.count ) {
        return nil;
    }
    
    UIImageView *img = [_imageViews objectAtIndex:page];
    if ((NSNull *)img == [NSNull null]) {
        img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.0, CGRectGetWidth(self.galleryPageView.frame), CGRectGetHeight(self.galleryPageView.frame))];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.userInteractionEnabled = YES;
        [_imageViews replaceObjectAtIndex:page withObject:img];
        img.tag = page;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewImage:)];
        [img addGestureRecognizer:tap];
    }
    
    if (img.superview == nil) {
        CGRect frame = img.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        img.frame = frame;
        TaoziImage *taoziImage = [_spot.images objectAtIndex:page];
        NSString *url = taoziImage.imageUrl;
        [img sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"spot_detail_default.png"]];
    }
    return img;
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
