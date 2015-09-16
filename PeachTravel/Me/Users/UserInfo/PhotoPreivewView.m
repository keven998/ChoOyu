//
//  PhotoPreivewView.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "PhotoPreivewView.h"

@interface PhotoPreivewView()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PhotoPreivewView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setupMainView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupMainView];
    NSLog(@"%@", NSStringFromCGRect(self.frame));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    // 基本尺寸参数
    CGSize boundsSize = _scrollView.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth*2, boundsHeight*2);
    _imageView.frame = imageFrame;
}

- (void)setupMainView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = _image;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    
    CGPoint touchPoint = [tap locationInView:self];
    if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1.5, 1.5) animated:YES];
    }
}



@end
