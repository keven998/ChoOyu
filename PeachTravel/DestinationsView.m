//
//  DestinationsView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "DestinationsView.h"

@interface DestinationsView ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation DestinationsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width-20, self.bounds.size.height)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.tag = self.tag;
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)setDestinations:(NSArray *)destinations
{
    _destinations = destinations;
    CGFloat offsetX = 0;
    for (int i = 0; i < _destinations.count; i++) {
        NSString *title = [_destinations objectAtIndex:i];
        CGSize size = [title sizeWithAttributes:@{NSFontAttributeName :[UIFont fontWithName:@"MicrosoftYaHei" size:11.0]}];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 7, 20+size.width, 16)];
        btn.layer.cornerRadius = 8.0;
        btn.tag = i;
        btn.backgroundColor = APP_THEME_COLOR;
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0];
        offsetX += btn.bounds.size.width + 20;
        [btn addTarget:self action:@selector(didSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:btn];
    }
    [_scrollView setContentSize:CGSizeMake(offsetX, self.bounds.size.height)];
}

- (IBAction)didSelected:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(distinationDidSelect:)]) {
        [_delegate distinationDidSelect:sender];
    }
}

@end



