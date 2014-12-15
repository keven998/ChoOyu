//
//  SpotDetailView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotDetailView.h"
#import "ResizableView.h"

@interface SpotDetailView ()

@property (nonatomic, strong) UIScrollView *galleryPageView;

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

@property (nonatomic, strong) UILabel *travelGuideLabel;
@property (nonatomic, strong) UILabel *kengdieLabel;
@property (nonatomic, strong) UILabel *trafficGuideLabel;

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
    
    UIScrollView *gallery = [[UIScrollView alloc]initWithFrame:CGRectMake(0, oy, width-22, 167.5)];
    gallery.pagingEnabled = YES;
    gallery.showsHorizontalScrollIndicator = NO;
    gallery.showsVerticalScrollIndicator = NO;
    gallery.delegate = self;
    gallery.bounces = YES;
    [_headerView addSubview:gallery];
    _galleryPageView = gallery;
    
    _imagePageIndicator = [[UIButton alloc] initWithFrame:CGRectMake(_headerView.frame.size.width-53.5, gallery.frame.size.height-33, 47.5, 23)];
    _imagePageIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_imagePageIndicator setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _imagePageIndicator.userInteractionEnabled = NO;
    _imagePageIndicator.layer.cornerRadius = 1.0;
    [_imagePageIndicator setTitle:[NSString stringWithFormat:@"1/%d", _spot.images.count] forState:UIControlStateNormal];
    [_headerView addSubview:_imagePageIndicator];
    
    int count = _spot.images.count;
    _galleryPageView.contentSize = CGSizeMake(CGRectGetWidth(_galleryPageView.frame) * count, CGRectGetHeight(_galleryPageView.frame));
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < count; i++)
    {
        [images addObject:[NSNull null]];
    }
    _imageViews = images;
    [self loadScrollViewWithPage:0];
    if (count > 1) {
        [self loadScrollViewWithPage:1];
    }
    
    oy += 175;
    
    _titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy, width-44, 30)];
    [_titleBtn setTitle:_spot.zhName forState:UIControlStateNormal];
    [_titleBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_titleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_titleBtn setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [_titleBtn setImage:[UIImage imageNamed:@"ic_spot.png"] forState:UIControlStateNormal];
    [_titleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    _titleBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_titleBtn];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-85, oy, 60, 30)];
    if (_spot.isMyFavorite) {
        [_favoriteBtn setImage:[UIImage imageNamed:@"ic_Favorite.png"] forState:UIControlStateNormal];
    } else {
        [_favoriteBtn setImage:[UIImage imageNamed:@"ic_unFavorite.png"] forState:UIControlStateNormal];
    }
    
    [_headerView addSubview:_favoriteBtn];
    
    oy += 35;
    
    _spot.desc = @"位于哈哈哈哈哈哈位于哈哈哈哈哈哈位于哈哈位于哈哈哈哈哈哈位于哈哈哈哈哈哈位于哈哈哈哈哈哈哈哈哈哈位于哈哈哈哈哈哈位于哈哈哈哈哈哈位于哈哈哈哈哈哈位于哈哈哈哈哈哈";
    
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(10, oy, width-44, 40)];
    _descView.contentFont = [UIFont systemFontOfSize:11.0];
    _descView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _descView.content = _spot.desc;
    [_headerView addSubview:_descView];
    
    oy += 35;
    
    if (_descView.maxNumberOfLine > 2) {
        _showMoreDescContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-50, oy+3, 20, 10)];
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
    
   
    _spot.priceDesc = @"淡季哈哈哈淡季哈哈";
    
    CGSize size = [_spot.priceDesc sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
    NSInteger lineCount = (size.width / (width-90)) + 1;
    CGFloat ticketHeight = lineCount*size.height < 45 ? 45:lineCount*size.height + 20;
    
    _ticketDescBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width-22, ticketHeight)];
    [_ticketDescBtn setTitle:_spot.priceDesc forState:UIControlStateNormal];
    [_ticketDescBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [_ticketDescBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_ticketDescBtn setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    _ticketDescBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _ticketDescBtn.userInteractionEnabled = NO;
    _ticketDescBtn.layer.cornerRadius = 2.0;
    _ticketDescBtn.titleLabel.numberOfLines = lineCount;
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
    
    _spot.travelMonth = @"最佳月份最佳月份最佳月份最佳月份最佳月份最佳月份";
    _spot.timeCostStr = @"最佳月份最佳月份最佳月份最佳月份最佳月份最佳月份";
    _spot.openTime = @"最佳月份最佳月份最佳月份最佳月份最佳月份最佳月份";

    if (![_spot.travelMonth isBlankString]) {
        
      
        
        NSAttributedString *travelMonthDetail = [[NSAttributedString alloc] initWithString:_spot.travelMonth
                                                                               attributes:@{
                                                                                            NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                                                            NSForegroundColorAttributeName : APP_THEME_COLOR
                                                                                            }];
        NSAttributedString *travelMonthTitle = [[NSAttributedString alloc] initWithString:@""
                                                                               attributes:@{
                                                                                           NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                                                           NSForegroundColorAttributeName : TEXT_COLOR_TITLE_SUBTITLE,
                                                                                           NSParagraphStyleAttributeName : paragraphStyle1
                                                                                           }];
        
        NSMutableAttributedString *travelStr = [[NSMutableAttributedString alloc] init];
        [travelStr appendAttributedString:travelMonthTitle];
        [travelStr appendAttributedString:travelMonthDetail];

        CGSize size = travelStr.size;
        NSInteger lineCount = (size.width / (width-80-50)) + 1;
        CGFloat height = lineCount * 20+20;
        
        _travelMonthBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, doy, width-40, height)];
        _travelMonthBtn.layer.cornerRadius = 4.0;
        [_travelMonthBtn setAttributedTitle:travelStr forState:UIControlStateNormal];
        _travelMonthBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _travelMonthBtn.layer.borderWidth = 0.5;
        _travelMonthBtn.titleLabel.numberOfLines = lineCount;
        
        _travelMonthBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 70, 0, 10);
        _travelMonthBtn.frame = CGRectMake(_travelMonthBtn.frame.origin.x, _travelMonthBtn.frame.origin.y, _travelMonthBtn.frame.size.width, height);
        [_travelMonthBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

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
        NSAttributedString *opentTimeDetail = [[NSAttributedString alloc] initWithString:_spot.openTime
                                                                                attributes:@{
                                                                                             NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                                                             NSForegroundColorAttributeName : APP_THEME_COLOR
                                                                                             }];
        NSAttributedString *opentTimeTitle = [[NSAttributedString alloc] initWithString:@""
                                                                               attributes:@{
                                                                                            NSFontAttributeName : [UIFont boldSystemFontOfSize:11.0],
                                                                                            NSForegroundColorAttributeName : TEXT_COLOR_TITLE_SUBTITLE,
                                                                                            NSParagraphStyleAttributeName : paragraphStyle1

                                                                                            }];
        
        NSMutableAttributedString *travelStr = [[NSMutableAttributedString alloc] init];
        [travelStr appendAttributedString:opentTimeTitle];
        [travelStr appendAttributedString:opentTimeDetail];
        
        CGSize size = travelStr.size;
        NSInteger lineCount = (size.width / (width-80 - 50)) + 1;
        CGFloat height = lineCount * 20+20;
        
        _openTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, doy, width-40, height)];
        _openTimeBtn.layer.cornerRadius = 4.0;
        [_openTimeBtn setAttributedTitle:travelStr forState:UIControlStateNormal];
        _openTimeBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _openTimeBtn.layer.borderWidth = 0.5;
        
        _openTimeBtn.titleLabel.numberOfLines = lineCount;
        _openTimeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 70, 0, 10);
        _openTimeBtn.frame = CGRectMake(_openTimeBtn.frame.origin.x, _openTimeBtn.frame.origin.y, _openTimeBtn.frame.size.width, height);
        [_openTimeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        UIButton *subTitle = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, _travelMonthBtn.frame.size.height)];
        [subTitle setTitle:@"开放时间" forState:UIControlStateNormal];
        [subTitle setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
        subTitle.titleLabel.font = [UIFont systemFontOfSize:11.0];
        subTitle.userInteractionEnabled = NO;
        [_openTimeBtn addSubview:subTitle];

        oy += height+10;
        doy += height+10;
    }
    if (![_spot.timeCostStr isBlankString]) {
        NSAttributedString *timeCostDetail = [[NSAttributedString alloc] initWithString:_spot.timeCostStr
                                                                                attributes:@{
                                                                                             NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                                                             NSForegroundColorAttributeName : APP_THEME_COLOR
                                                                                             }];
        NSAttributedString *timeCostTitle = [[NSAttributedString alloc] initWithString:@""
                                                                               attributes:@{
                                                                                            NSFontAttributeName : [UIFont boldSystemFontOfSize:11.0],
                                                                                            NSForegroundColorAttributeName : TEXT_COLOR_TITLE_SUBTITLE,
                                                                                            NSParagraphStyleAttributeName : paragraphStyle1

                                                                                            }];
        
        NSMutableAttributedString *travelStr = [[NSMutableAttributedString alloc] init];
        [travelStr appendAttributedString:timeCostTitle];
        [travelStr appendAttributedString:timeCostDetail];
        
        CGSize size = travelStr.size;
        NSInteger lineCount = (size.width / (width-80-50)) + 1;
        CGFloat height = lineCount * 20+20;
        
        _timeCostBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, doy, width-40, height)];
        _timeCostBtn.layer.cornerRadius = 4.0;
        [_timeCostBtn setAttributedTitle:travelStr forState:UIControlStateNormal];
        _timeCostBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _timeCostBtn.layer.borderWidth = 0.5;
        _timeCostBtn.titleLabel.numberOfLines = lineCount;
        _timeCostBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 70, 0, 10);
        _timeCostBtn.frame = CGRectMake(_timeCostBtn.frame.origin.x, _timeCostBtn.frame.origin.y, _timeCostBtn.frame.size.width, height);
        [_timeCostBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        UIButton *subTitle = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, _travelMonthBtn.frame.size.height)];
        [subTitle setTitle:@"参考时长" forState:UIControlStateNormal];
        [subTitle setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
        subTitle.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [_timeCostBtn addSubview:subTitle];
        subTitle.userInteractionEnabled = NO;

        oy += height+10;
        doy += height+10;
    }
    
#warning 测试数据
    _spot.address = @"位于平顶山，平顶庙，平顶嘀dsfsSD 见风使舵离开家发了斯";
    
    size = [_spot.address sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:12.0]}];
    lineCount = (size.width / (width-100)) + 1;
    CGFloat addressHeight = lineCount*size.height+20 < 57.5 ? 57.5 : lineCount*size.height+20;
    
    _addressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width-22, addressHeight)];
    _addressBtn.titleLabel.numberOfLines = lineCount;
    [_addressBtn setTitle:_spot.address forState:UIControlStateNormal];
    _addressBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _addressBtn.backgroundColor = [UIColor whiteColor];
    _addressBtn.layer.cornerRadius = 2.0;
    _addressBtn.titleLabel.numberOfLines = lineCount;
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
    
#warning 测试数据
_spot.guideUrl = @"http://";
_spot.trafficInfoUrl = @"http://";
_spot.kengdieUrl = @"http://";

    if (![_spot.guideUrl isBlankString]) {
        _travelGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(ox, doy, 60, 60)];
        [_travelGuideBtn setImage:[UIImage imageNamed:@"travel_guide_unselected.png"] forState:UIControlStateNormal];
        [_travelGuideBtn setImage:[UIImage imageNamed:@"travel_guide_selected.png"] forState:UIControlStateHighlighted];
        
        _travelGuideLabel = [[UILabel alloc] initWithFrame:CGRectMake(ox, doy+65, 60, 20)];
        _travelGuideLabel.font = [UIFont systemFontOfSize:11.0];
        _travelGuideLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        _travelGuideLabel.text = @"游玩指南";
        _travelGuideLabel.textAlignment = NSTextAlignmentCenter;
        ox += space+60;
        hasAdd = YES;
    }
    
    if (![_spot.kengdieUrl isBlankString]) {
        _kendieBtn = [[UIButton alloc] initWithFrame:CGRectMake(ox, doy, 60, 60)];
        [_kendieBtn setImage:[UIImage imageNamed:@"kengdie_guide_unselected.png"] forState:UIControlStateNormal];
        [_kendieBtn setImage:[UIImage imageNamed:@"kengdie_guide_selected.png"] forState:UIControlStateHighlighted];
        
        _kengdieLabel = [[UILabel alloc] initWithFrame:CGRectMake(ox, doy+65, 60, 20)];
        _kengdieLabel.text = @"防坑攻略";
        _kengdieLabel.textAlignment = NSTextAlignmentCenter;
        _kengdieLabel.font = [UIFont systemFontOfSize:11.0];
        _kengdieLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        ox += space+60;
        hasAdd = YES;

    }
    
    if (![_spot.trafficInfoUrl isBlankString]) {
        _trafficGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(ox, doy, 60, 60)];
        [_trafficGuideBtn setImage:[UIImage imageNamed:@"traffic_guide_unselected.png"] forState:UIControlStateNormal];
        [_trafficGuideBtn setImage:[UIImage imageNamed:@"traffic_guide_selected.png"] forState:UIControlStateHighlighted];
        
        _trafficGuideLabel = [[UILabel alloc] initWithFrame:CGRectMake(ox, doy+65, 60, 20)];
        _trafficGuideLabel.text = @"交通指南";
        _trafficGuideLabel.textAlignment = NSTextAlignmentCenter;
        _trafficGuideLabel.font = [UIFont systemFontOfSize:11.0];
        _trafficGuideLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
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
    [_detailView addSubview:_travelGuideLabel];
    [_detailView addSubview:_kengdieLabel];
    [_detailView addSubview:_trafficGuideLabel];

    [self addSubview:_detailView];
    
    
    [self setContentSize:CGSizeMake(self.frame.size.width, oy+110)];
    [self addSubview:_headerView];
    
}

- (void)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= _spot.images.count) {
        return;
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
        [self.galleryPageView insertSubview:img atIndex:0];
        TaoziImage *taoziImage = [_spot.images objectAtIndex:page];
        NSString *url = taoziImage.imageUrl;
        [img sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"spot_detail_default.png"]];
    }
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
}

- (IBAction)viewImage:(id)sender
{
    
}

#pragma scrolldelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _galleryPageView) {
        CGFloat pageWidth = CGRectGetWidth(self.galleryPageView.frame);
        NSUInteger page = floor((self.galleryPageView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
        [_imagePageIndicator setTitle:[NSString stringWithFormat:@"%d/%d",page+1, _spot.images.count] forState:UIControlStateNormal];
    }
}



@end
