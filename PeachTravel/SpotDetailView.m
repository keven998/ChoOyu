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
@property (nonatomic, strong) UIButton *addressBtn;
@property (nonatomic, strong) UIButton *travelGuideBtn;
@property (nonatomic, strong) UIButton *kendieBtn;
@property (nonatomic, strong) UIButton *trafficGuideBtn;
@property (nonatomic, strong) UILabel *travelGuideLabel;
@property (nonatomic, strong) UILabel *kengdieLabel;
@property (nonatomic, strong) UILabel *trafficGuideLabel;

@end

@implementation SpotDetailView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xf4f4f4);
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
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10+64, width-20, 280)];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.layer.cornerRadius = 2.0;
    
    UIScrollView *gallery = [[UIScrollView alloc]initWithFrame:CGRectMake(0, oy, width-20, 176.0)];
    gallery.pagingEnabled = YES;
    gallery.showsHorizontalScrollIndicator = NO;
    gallery.showsVerticalScrollIndicator = NO;
    gallery.delegate = self;
    gallery.bounces = YES;
    [_headerView addSubview:gallery];
    _galleryPageView = gallery;
    
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
    
    oy += 180;
    
    _titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy, width-40, 30)];
    [_titleBtn setTitle:_spot.zhName forState:UIControlStateNormal];
    [_titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_titleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_titleBtn setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _titleBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_titleBtn];
    
    oy += 35;
    
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(10, oy, width-40, 40)];
    _descView.font = [UIFont systemFontOfSize:15.0];
    _descView.textColor = [UIColor grayColor];
    _descView.content = _spot.desc;
    [_headerView addSubview:_descView];
    
    oy += 40;
    
    _showMoreDescContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-50, oy+3, 20, 10)];
    [_showMoreDescContentBtn setBackgroundColor:[UIColor grayColor]];
    [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_showMoreDescContentBtn];
    
    oy += 20;
    
    CGFloat doy = 0;
    
    _ticketBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width-20, 30)];
    [_ticketBtn setTitle:@"门票" forState:UIControlStateNormal];
    [_ticketBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_ticketBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_ticketBtn setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    _ticketBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _ticketBtn.backgroundColor = [UIColor whiteColor];
    [_ticketBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    _ticketBtn.userInteractionEnabled = NO;
    
    CGSize size = [_spot.priceDesc sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
    NSInteger lineCount = (size.width / (width-80)) + 1;
    CGFloat ticketHeight = lineCount*size.height;
    
    doy += 30;
    oy += 30;
    
    _ticketDescBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, doy, width-40, ticketHeight)];
    [_ticketDescBtn setTitle:_spot.priceDesc forState:UIControlStateNormal];
    [_ticketDescBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_ticketDescBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_ticketDescBtn setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    _ticketDescBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _ticketDescBtn.userInteractionEnabled = NO;
    
    doy += ticketHeight + 20;
    oy += ticketHeight + 20;
    
    _travelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width-20, 30)];
    [_travelBtn setTitle:@"游玩" forState:UIControlStateNormal];
    [_travelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_travelBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_travelBtn setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    _travelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [_travelBtn setBackgroundColor:[UIColor whiteColor]];
    [_travelBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    _travelBtn.userInteractionEnabled = NO;
    
    doy += 40;
    oy += 40;
    _spot.travelMonth = @"最佳月份最佳月份最佳月份最佳月份最佳月份最佳月份";
    if (_spot.travelMonth) {
        NSAttributedString *travelMonthDetail = [[NSAttributedString alloc] initWithString:_spot.travelMonth
                                                                               attributes:@{
                                                                                            NSFontAttributeName : [UIFont systemFontOfSize:16.0],
                                                                                            NSForegroundColorAttributeName : UIColorFromRGB(0xee528c)
                                                                                            }];
        NSAttributedString *travelMonthTitle = [[NSAttributedString alloc] initWithString:@"最佳月份  "
                                                                               attributes:@{
                                                                                           NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                                                                                           NSForegroundColorAttributeName : [UIColor grayColor]
                                                                                           }];
        
        NSMutableAttributedString *travelStr = [[NSMutableAttributedString alloc] init];
        [travelStr appendAttributedString:travelMonthTitle];
        [travelStr appendAttributedString:travelMonthDetail];

        CGSize size = travelStr.size;
        NSInteger lineCount = (size.width / (width-80)) + 1;
        CGFloat height = lineCount * 20+10;
        
        _travelMonthBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, doy, width-40, height)];
        _travelMonthBtn.layer.cornerRadius = 2.0;
        [_travelMonthBtn setAttributedTitle:travelStr forState:UIControlStateNormal];
        _travelMonthBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _travelMonthBtn.layer.borderWidth = 1;
        _travelMonthBtn.titleLabel.numberOfLines = lineCount;
        _travelMonthBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _travelMonthBtn.frame = CGRectMake(_travelMonthBtn.frame.origin.x, _travelMonthBtn.frame.origin.y, _travelMonthBtn.frame.size.width, height);
        [_travelMonthBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

        oy += height+10;
        doy += height+10;
    }
    if (_spot.openTime) {
        NSAttributedString *travelMonthDetail = [[NSAttributedString alloc] initWithString:_spot.openTime
                                                                                attributes:@{
                                                                                             NSFontAttributeName : [UIFont systemFontOfSize:16.0],
                                                                                             NSForegroundColorAttributeName : UIColorFromRGB(0xee528c)
                                                                                             }];
        NSAttributedString *travelMonthTitle = [[NSAttributedString alloc] initWithString:@"开放时间  "
                                                                               attributes:@{
                                                                                            NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                                                                                            NSForegroundColorAttributeName : [UIColor grayColor]
                                                                                            }];
        
        NSMutableAttributedString *travelStr = [[NSMutableAttributedString alloc] init];
        [travelStr appendAttributedString:travelMonthTitle];
        [travelStr appendAttributedString:travelMonthDetail];
        
        CGSize size = travelStr.size;
        NSInteger lineCount = (size.width / (width-80)) + 1;
        CGFloat height = lineCount * 20+10;
        
        _openTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, doy, width-40, height)];
        _openTimeBtn.layer.cornerRadius = 2.0;
        [_openTimeBtn setAttributedTitle:travelStr forState:UIControlStateNormal];
        _openTimeBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _openTimeBtn.layer.borderWidth = 1;
        
        _openTimeBtn.titleLabel.numberOfLines = lineCount;
        _openTimeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _openTimeBtn.frame = CGRectMake(_openTimeBtn.frame.origin.x, _openTimeBtn.frame.origin.y, _openTimeBtn.frame.size.width, height);
        [_openTimeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

        oy += height+10;
        doy += height+10;
    }
    if (_spot.timeCostStr) {
        NSAttributedString *travelMonthDetail = [[NSAttributedString alloc] initWithString:_spot.timeCostStr
                                                                                attributes:@{
                                                                                             NSFontAttributeName : [UIFont systemFontOfSize:16.0],
                                                                                             NSForegroundColorAttributeName : UIColorFromRGB(0xee528c)
                                                                                             }];
        NSAttributedString *travelMonthTitle = [[NSAttributedString alloc] initWithString:@"游玩时间  "
                                                                               attributes:@{
                                                                                            NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                                                                                            NSForegroundColorAttributeName : [UIColor grayColor]
                                                                                            }];
        
        NSMutableAttributedString *travelStr = [[NSMutableAttributedString alloc] init];
        [travelStr appendAttributedString:travelMonthTitle];
        [travelStr appendAttributedString:travelMonthDetail];
        
        CGSize size = travelStr.size;
        NSInteger lineCount = (size.width / (width-80)) + 1;
        CGFloat height = lineCount * 20+10;
        
        _timeCostBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, doy, width-40, height)];
        _timeCostBtn.layer.cornerRadius = 2.0;
        [_timeCostBtn setAttributedTitle:travelStr forState:UIControlStateNormal];
        _timeCostBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _timeCostBtn.layer.borderWidth = 1;
        _timeCostBtn.titleLabel.numberOfLines = lineCount;
        _timeCostBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _timeCostBtn.frame = CGRectMake(_timeCostBtn.frame.origin.x, _timeCostBtn.frame.origin.y, _timeCostBtn.frame.size.width, height);
        [_timeCostBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        oy += height+10;
        doy += height+10;
    }
    
#warning 测试数据
    _spot.address = @"位于平顶山，平顶庙，平顶嘀嗒嘀嗒嘀嗒";
    
    size = [_spot.address sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:16.0]}];
    lineCount = (size.width / (width-80)) + 1;
    CGFloat addressHeight = lineCount*size.height+10;
    
    _addressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width-20, addressHeight)];
    [_addressBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    _addressBtn.titleLabel.numberOfLines = lineCount;
    [_addressBtn setTitle:_spot.address forState:UIControlStateNormal];
    _addressBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    _addressBtn.backgroundColor = [UIColor whiteColor];
    _addressBtn.layer.cornerRadius = 2.0;
    [_addressBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_addressBtn addTarget:self action:@selector(jumpToMapview:) forControlEvents:UIControlEventTouchUpInside];
    
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
        [_travelGuideBtn setBackgroundColor:[UIColor grayColor]];
        [_travelGuideBtn addTarget:self action:@selector(travelGuide:) forControlEvents:UIControlEventTouchUpInside];
        
        _travelGuideLabel = [[UILabel alloc] initWithFrame:CGRectMake(ox, doy+70, 60, 20)];
        _travelGuideLabel.font = [UIFont systemFontOfSize:15.0];
        _travelGuideLabel.textColor = [UIColor grayColor];
        _travelGuideLabel.text = @"游玩指南";
        ox += space+60;
        hasAdd = YES;
    }
    
    if (![_spot.kengdieUrl isBlankString]) {
        _kendieBtn = [[UIButton alloc] initWithFrame:CGRectMake(ox, doy, 60, 60)];
        [_kendieBtn setBackgroundColor:[UIColor grayColor]];
        [_kendieBtn addTarget:self action:@selector(kengdie:) forControlEvents:UIControlEventTouchUpInside];
        
        _kengdieLabel = [[UILabel alloc] initWithFrame:CGRectMake(ox, doy+70, 60, 20)];
        _kengdieLabel.text = @"防坑攻略";
        _kengdieLabel.font = [UIFont systemFontOfSize:15.0];
        _kengdieLabel.textColor = [UIColor grayColor];
        ox += space+60;
        hasAdd = YES;

    }
    
    if (![_spot.trafficInfoUrl isBlankString]) {
        _trafficGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(ox, doy, 60, 60)];
        [_trafficGuideBtn setBackgroundColor:[UIColor grayColor]];
        [_trafficGuideBtn addTarget:self action:@selector(trafficGuide:) forControlEvents:UIControlEventTouchUpInside];
        
        _trafficGuideLabel = [[UILabel alloc] initWithFrame:CGRectMake(ox, doy+70, 60, 20)];
        _trafficGuideLabel.text = @"交通指南";
        _trafficGuideLabel.font = [UIFont systemFontOfSize:15.0];
        _trafficGuideLabel.textColor = [UIColor grayColor];
        hasAdd = YES;
    }
    if (hasAdd) {
        oy += 100;
        doy += 100;
    }
   
    
    _detailView = [[UIView alloc] initWithFrame:CGRectMake(10, _headerView.frame.origin.y+_headerView.frame.size.height+20, width-20, doy+10)];
    _detailView.backgroundColor = [UIColor clearColor];
    [_detailView addSubview:_ticketBtn];
    [_detailView addSubview:_ticketDescBtn];
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
        img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.0, self.bounds.size.width, CGRectGetHeight(self.galleryPageView.frame))];
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
    }];
    [self setContentSize:CGSizeMake(self.contentSize.width, self.contentSize.height+_descView.resizeHeight)];
    [_showMoreDescContentBtn removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_showMoreDescContentBtn addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)hideContent:(id)sender
{
    [_descView hideContent];
    [UIView animateWithDuration:0.2 animations:^{
        [_headerView setFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height - _descView.resizeHeight)];
        [_showMoreDescContentBtn setFrame:CGRectMake(_showMoreDescContentBtn.frame.origin.x, _showMoreDescContentBtn.frame.origin.y - _descView.resizeHeight, _showMoreDescContentBtn.frame.size.width, _showMoreDescContentBtn.frame.size.height)];
         [_detailView setFrame:CGRectMake(_detailView.frame.origin.x, _detailView.frame.origin.y-_descView.resizeHeight, _detailView.frame.size.width, _detailView.frame.size.height)];
    }];
    [self setContentSize:CGSizeMake(self.contentSize.width, self.contentSize.height-_descView.resizeHeight)];
    [_showMoreDescContentBtn removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)travelGuide:(id)sender
{
    
}

- (IBAction)kengdie:(id)sender
{
    
}

- (IBAction)trafficGuide:(id)sender
{
    
}

- (IBAction)viewImage:(id)sender
{
    
}

- (IBAction)jumpToMapview:(id)sender
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
    }
}

@end
