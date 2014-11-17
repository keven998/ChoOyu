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

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) ResizableView *descView;
@property (nonatomic, strong) UIButton *ticketBtn;
@property (nonatomic, strong) UIButton *ticketDescBtn;
@property (nonatomic, strong) UIButton *travelBtn;
@property (nonatomic, strong) UILabel *travelMonthLabel;
@property (nonatomic, strong) UILabel *openTimeLabel;
@property (nonatomic, strong) UILabel *timeCostLabel;
@property (nonatomic, strong) UILabel *addressBtn;
@property (nonatomic, strong) UIButton *travleGuideBtn;
@property (nonatomic, strong) UIButton *kendieBtn;
@property (nonatomic, strong) UIButton *trafficGuideBtn;

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
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10+64, width-20, 280)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.layer.cornerRadius = 2.0;
    
    UIScrollView *gallery = [[UIScrollView alloc]initWithFrame:CGRectMake(0, oy, width, 176.0)];
    gallery.pagingEnabled = YES;
    gallery.showsHorizontalScrollIndicator = NO;
    gallery.showsVerticalScrollIndicator = NO;
    gallery.delegate = self;
    gallery.bounces = YES;
    [headerView addSubview:gallery];
    
    oy += 180;
    
    _titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, oy, width-20, 40)];
    [_titleBtn setTitle:_spot.enName forState:UIControlStateNormal];
    _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [headerView addSubview:_titleBtn];
    
    oy += 45;
    
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(10, oy, width-40, 40)];
    _descView.font = [UIFont systemFontOfSize:15.0];
    _descView.textColor = [UIColor grayColor];
    _descView.text = _spot.desc;
    [headerView addSubview:_descView];
    
    oy += 40;
    
    UIButton *showMoreDescContent = [[UIButton alloc] initWithFrame:CGRectMake(width-30, oy+3, 20, 20)];
    [showMoreDescContent setBackgroundColor:[UIColor grayColor]];
    [showMoreDescContent addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:showMoreDescContent];
    
    [self addSubview:headerView];
    
    
    
    
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
        TaoziImage *taoziIamge = [_spot.images objectAtIndex:page];
        NSString *url = taoziIamge.imageUrl;
        if ([url rangeOfString:@"qiniudn"].location != NSNotFound) {
        }
    }
}

#pragma mark - IBAction Methods

- (IBAction)showMoreContent:(id)sender
{
    
}

- (IBAction)<#selector#>:(id)sender)

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
