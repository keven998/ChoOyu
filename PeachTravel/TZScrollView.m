//
//  TZScrollView.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "TZScrollView.h"

@interface TZScrollView()

@end

@implementation TZScrollView

#pragma mark - setter & getter

- (void)setViewsOnScrollView:(NSMutableArray *)viewsOnScrollView
{
    _viewsOnScrollView = viewsOnScrollView;
    [self setNeedsDisplay];
}

//用户发生了滑动操作，然后将 scrollview 滑动到正确位置
- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    [self scrollToCorrectPosition];
}

- (void)drawRect:(CGRect)rect {
    _scrollView.contentSize = CGSizeMake(_viewsOnScrollView.count *_itemWidth+self.bounds.size.width, _scrollView.contentSize.height);
    for (UIView *subview in _scrollView.subviews) {
        [subview removeFromSuperview];
    }
    for (int i = 0; i < _viewsOnScrollView.count; i++) {
        UIButton *contentView = [_viewsOnScrollView objectAtIndex:i];
        CGRect frame = CGRectMake(_itemWidth * i+self.bounds.size.width/2, 0, _itemWidth, _itemHeight);
        [_viewsOnScrollView[i] setFrame:frame];
        [_scrollView addSubview:contentView];
    }
    if (self.viewsOnScrollView.count) {
        self.currentIndex = 0;
    }
}

- (void)scrollToCorrectPosition
{
    CGPoint currentOffset = _scrollView.contentOffset;
    CGPoint midPoint = self.center;
    CGPoint indexPoint = [self convertPoint:midPoint toView:self.scrollView];
    CGPoint currentPoint = ((UIButton *)_viewsOnScrollView[_currentIndex]).frame.origin;
    CGFloat length = currentOffset.x - (indexPoint.x - currentPoint.x-_itemWidth/2);
    [_scrollView setContentOffset:CGPointMake(length, 0) animated:YES] ;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(155, 0, 10, 10)];
        indicatorView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_scrollView];
        [self addSubview:indicatorView];
    }
    return self;
}

- (void)awakeFromNib
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, _itemHeight)];
    [self addSubview:_scrollView];
}

@end


