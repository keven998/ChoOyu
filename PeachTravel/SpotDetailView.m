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
//@property (nonatomic, strong) UIButton

@end

@implementation SpotDetailView

@synthesize spot;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubView];
    }
    return self;
}

- (void)setupSubView
{
    CGFloat oy = 0;
    CGFloat width = self.frame.size.width;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, width-20, 250)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *gallery = [[UIScrollView alloc]initWithFrame:CGRectMake(0, oy, width, 176.0)];
    gallery.pagingEnabled = YES;
    gallery.showsHorizontalScrollIndicator = NO;
    gallery.showsVerticalScrollIndicator = NO;
    gallery.delegate = self;
    gallery.bounces = YES;
    
    [headerView addSubview:gallery];
    
    
    
    oy+=176.0;
    
    
}

- (void)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= spot.pictures.count) {
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
        NSString *url = [spot.pictures objectAtIndex:page];
        if ([url rangeOfString:@"qiniudn"].location != NSNotFound) {
        }
    }
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
