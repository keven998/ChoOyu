//
//  TZScrollView.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "TZScrollView.h"

@interface TZScrollView() <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

#define spaceWidth  20.0

@end

@implementation TZScrollView

#pragma mark - setter & getter

- (void)setViewsOnScrollView:(NSMutableArray *)viewsOnScrollView
{
    _viewsOnScrollView = viewsOnScrollView;
    [self setNeedsDisplay];
}

- (void)setTitles:(NSArray *)titles
{
    _scrollView.contentSize = CGSizeMake(titles.count *(_itemWidth + spaceWidth)+self.bounds.size.width, _scrollView.contentSize.height);

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i<[titles count]; i++) {
        
        CGRect frame = CGRectMake((spaceWidth+_itemWidth) * i+self.bounds.size.width/2, (self.frame.size.height-_itemHeight)/2, _itemWidth, _itemHeight);

        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        NSString *s = [titles objectAtIndex:i];
        [button setTitle:s forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        button.layer.cornerRadius = _itemHeight/2;
        [button setBackgroundColor:_itemBackgroundColor];
        button.tag = i;
        [array addObject:button];
        [self.scrollView addSubview:button];
    }
    
    _viewsOnScrollView = array;
    for (UIButton *tempBtn in _viewsOnScrollView) {
        [tempBtn addTarget:self action:@selector(choseCurrent:) forControlEvents:UIControlEventTouchUpInside];
    }
    
       if (self.viewsOnScrollView.count) {
        self.currentIndex = 0;
    }

}

//用户发生了滑动操作，然后将 scrollview 滑动到正确位置
- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    //如果scrollview 上一个 cell 都没有的话直接 return 掉
    if (_currentIndex == 0 && self.viewsOnScrollView.count == 0) {
        return;
    }
    [self scrollToCorrectPosition];
}

- (IBAction)choseCurrent:(UIButton *)sender
{
    self.currentIndex = sender.tag;
    [_delegate moveToIndex:sender.tag];
}


- (void)scrollToCorrectPosition
{
    CGPoint currentOffset = _scrollView.contentOffset;
    CGPoint midPoint = self.center;
    CGPoint indexPoint = [self convertPoint:midPoint toView:self.scrollView];
    CGPoint currentPoint = ((UIButton *)_viewsOnScrollView[_currentIndex]).frame.origin;
    CGFloat length = currentOffset.x - (indexPoint.x - currentPoint.x-_itemWidth/2);
    if (length<10) {
        length = 10;
    }
    [_scrollView setContentOffset:CGPointMake(length, 0) animated:YES] ;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    
    int currentIndex = (int)(currentOffset.x+10)/(_itemWidth + spaceWidth);
    if (currentIndex > ([_viewsOnScrollView count] -1)) {
        currentIndex = [_viewsOnScrollView count] - 1;
    }
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    CGFloat offset = currentOffset.x - (_itemWidth + spaceWidth)*currentIndex;
    if (offset<0) {
        offset = 0;
    }
    if (offset>10) {
        offset = 20-offset;
        if (offset<0) {
            offset=0;
        }
    }
    
    CGFloat x = (spaceWidth+_itemWidth) * currentIndex+self.bounds.size.width/2;

    UIButton *btn = [_viewsOnScrollView objectAtIndex:currentIndex];
    CGRect rect = CGRectMake(x-(offset/2), (self.frame.size.height-_itemHeight)/2-(offset/2), _itemWidth+offset, _itemWidth+offset);
    btn.layer.cornerRadius = (_itemWidth+offset)/2;
    [btn setFrame:rect];
    btn.backgroundColor = UIColorFromRGB(0xee528c);
    
    for (int i=0; i<_viewsOnScrollView.count; i++) {
        UIButton *otherbtn = [_viewsOnScrollView objectAtIndex:i];
        if (![btn isEqual:otherbtn]) {
            CGFloat x = (spaceWidth+_itemWidth) * i+self.bounds.size.width/2;
            [otherbtn setFrame:CGRectMake(x,(self.frame.size.height-_itemHeight)/2, _itemWidth, _itemWidth)];
            otherbtn.layer.cornerRadius = _itemWidth/2;
            [otherbtn setBackgroundColor:_itemBackgroundColor];
        }
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    
    int currentIndex = (int)(currentOffset.x+10)/(_itemWidth + spaceWidth);
    if (currentIndex > ([_viewsOnScrollView count] -1)) {
        currentIndex = [_viewsOnScrollView count] - 1;
    }
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    self.currentIndex = currentIndex;
    [_delegate moveToIndex:currentIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGPoint currentOffset = scrollView.contentOffset;
    
    int currentIndex = (int)(currentOffset.x+10)/(_itemWidth + spaceWidth);
    if (currentIndex > ([_viewsOnScrollView count] -1)) {
        currentIndex = [_viewsOnScrollView count] - 1;
    }
    if (currentIndex < 0) {
        currentIndex = 0;
    }
//    NSLog(@"应该滚动的位置是:%d", currentIndex);
    self.currentIndex = currentIndex;
    [_delegate moveToIndex:currentIndex];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        UIImageView *indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-4, frame.size.height-4, 8, 4)];
        indicatorView.image = [UIImage imageNamed:@"TZScrollView_indicator.png"];
        [self addSubview:_scrollView];
        [self addSubview:indicatorView];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return self;
}

- (void)awakeFromNib
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, _itemHeight)];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;

    [self addSubview:_scrollView];
}

@end


