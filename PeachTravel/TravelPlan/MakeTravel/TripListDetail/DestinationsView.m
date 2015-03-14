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
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width-20, self.bounds.size.height)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;

        _scrollView.tag = self.tag;
        [self addSubview:_scrollView];
        
        if (!_titleColor) {
            _titleColor = TEXT_COLOR_TITLE_HINT;
        }
    }
    return self;
}

- (void)setDestinations:(NSArray *)destinations
{
    _destinations = destinations;
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    if (!_isCanAddDestination) {
        CGFloat offsetX = 0;
        for (int i = 0; i < _destinations.count; i++) {
            NSString *title = [_destinations objectAtIndex:i];
            CGSize size = [title sizeWithAttributes:@{NSFontAttributeName :[UIFont fontWithName:@"MicrosoftYaHei" size:10.0]}];
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 7, 10+size.width, 16)];
            btn.tag = i;
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:_titleColor forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:10.0];
            offsetX += btn.bounds.size.width + 10;
            [_scrollView addSubview:btn];
        }
        [_scrollView setContentSize:CGSizeMake(offsetX, self.bounds.size.height)];
        
    } else {
        CGFloat offsetX = 0;
        CGFloat offsetY = 10;
        for (int i = 0; i < _destinations.count; i++) {
            NSString *title = [_destinations objectAtIndex:i];
            CGSize size = [title sizeWithAttributes:@{NSFontAttributeName :[UIFont fontWithName:@"MicrosoftYaHei" size:13.0]}];
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, 40+size.width, 30)];
            btn.layer.borderWidth = 0.5;
            btn.layer.borderColor = APP_THEME_COLOR.CGColor;
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:_titleColor forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
            btn.layer.cornerRadius = 2.0;
            btn.tag = i;
            offsetX += btn.bounds.size.width + 20;
            
            NSString *nextTitle = [_destinations objectAtIndex:i];
            CGSize nextSize = [nextTitle sizeWithAttributes:@{NSFontAttributeName :[UIFont fontWithName:@"MicrosoftYaHei" size:13.0]}];

            if (offsetX+nextSize.width+60 >_scrollView.bounds.size.width) {
                offsetY += 50;
                offsetX = 0;
            }
            [btn addTarget:self action:@selector(didSelected:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:btn];
            if (i == _destinations.count-1) {
                UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, 70, 30)];
                [addBtn setImage:[UIImage imageNamed:@"ic_destination_add_normal.png"] forState:UIControlStateNormal];
                [addBtn setImage:[UIImage imageNamed:@"ic_destination_add_selected.png"] forState:UIControlStateHighlighted];
                addBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [addBtn addTarget:self action:@selector(willAddDestination:) forControlEvents:UIControlEventTouchUpInside];
                [_scrollView addSubview:addBtn];
            }
        }
        
        [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, offsetY+50)];
    }
   
}

- (IBAction)didSelected:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(destinationDidSelect:)]) {
        [_delegate destinationDidSelect:sender.tag];
    }
}

- (IBAction)willAddDestination:(id)sender
{
    if ([_delegate respondsToSelector:@selector(willAddDestination)]) {
        [_delegate willAddDestination];
    }
}

@end



