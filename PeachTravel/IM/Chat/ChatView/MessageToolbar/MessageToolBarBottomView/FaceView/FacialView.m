/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "FacialView.h"
#import "Emoji.h"

@interface FacialView ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
}
@end

@implementation FacialView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _faces = [Emoji allEmoji];
    }
    return self;
}


//给faces设置位置
-(void)loadFacialView:(int)page size:(CGSize)size
{
	int maxRow = 3;
    int maxCol = 7;
    CGFloat itemWidth = self.frame.size.width / maxCol;
//    CGFloat itemHeight = self.frame.size.height / maxRow;
    CGFloat itemHeight = self.frame.size.height / 4;
    
    
    _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width*2, self.bounds.size.height);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.delegate = self;
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    _pageControl.center = CGPointMake(SCREEN_WIDTH/2, self.bounds.size.height-20);
    _pageControl.numberOfPages = 2;
    [self addSubview:_pageControl];
    
    
    self.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setBackgroundColor:[UIColor clearColor]];

    [deleteButton setFrame:CGRectMake((maxCol -0.7) * itemWidth - 20, (maxRow - 1) * itemHeight, itemWidth , itemHeight)];
    
    [deleteButton setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
    deleteButton.tag = 10000;

    [deleteButton addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setFrame:CGRectMake((maxCol - 1) * itemWidth-20, (maxRow) * itemHeight + 5, itemWidth+10, itemHeight-10)];
    [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    sendButton.backgroundColor = APP_THEME_COLOR;
    sendButton.layer.cornerRadius = 2.0;
    
    
    for (int row = 0; row < maxRow; row++) {
        for (int col = 0; col < maxCol; col++) {
            int index = row * maxCol + col;
            if (index < 20) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setBackgroundColor:[UIColor clearColor]];
                [button setFrame:CGRectMake(col * itemWidth, row * itemHeight, itemWidth, itemHeight)];
                [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
                [button setTitle: [_faces objectAtIndex:(row * maxCol + col)] forState:UIControlStateNormal];
                button.tag = row * maxCol + col;
                [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                [_scrollView addSubview:button];
            }
     
            else{
                break;
            }
        }
        for (int col = 0; col < maxCol; col++) {
            int index = row * maxCol + col ;
            if (index < 17) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setBackgroundColor:[UIColor clearColor]];
                [button setFrame:CGRectMake((col+7) * itemWidth, row * itemHeight, itemWidth, itemHeight)];
                [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
                [button setTitle: [_faces objectAtIndex:(row * maxCol + col+18)] forState:UIControlStateNormal];
                button.tag = row * maxCol + col;
                [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
                [_scrollView addSubview:button];
            }
            
            else{
                break;
            }
        }
    }
    
    
    
    
    [self addSubview:_scrollView];
    [self addSubview:deleteButton];
    [self addSubview:sendButton];
}

-(void)dealPageControl:(UIPageControl *)pageControl
{
    double x = _scrollView.frame.size.width *pageControl.currentPage;
    [_scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollVi
{
    int index = (int)_scrollView.contentOffset.x / _scrollView.frame.size.width;
    _pageControl.currentPage = index;
}

-(void)selected:(UIButton*)bt
{
    if (bt.tag == 10000 && _delegate) {
        [_delegate deleteSelected:nil];
    }else{
        NSString *str = [_faces objectAtIndex:bt.tag];
        if (_delegate) {
            [_delegate selectedFacialView:str];
        }
    }
}

- (void)sendAction:(id)sender
{
    if (_delegate) {
        [_delegate sendFace];
    }
}

@end
