//
//  ResizableView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ResizableView.h"

@interface ResizableView ()

@property (nonatomic) CGRect resetFrame;
@property (nonatomic) BOOL shouldShowMoreContent;

@end

@implementation ResizableView

- (void)setContent:(NSString *)content
{
    _content = content;
    [self setTitle:_content forState:UIControlStateNormal];
}

- (void)setContentColor:(UIColor *)contentColor
{
    _contentColor = contentColor;
    [self setTitleColor:contentColor forState:UIControlStateNormal];
}

- (void)setNumberOfLine:(NSUInteger)numberOfLine
{
    _numberOfLine = numberOfLine;
    self.titleLabel.numberOfLines = _numberOfLine;
}

- (void)setContentFont:(UIFont *)contentFont
{
    _contentFont = contentFont;
    self.titleLabel.font = _contentFont;
}

- (NSInteger)maxNumberOfLine
{
    CGSize size = [_content sizeWithAttributes:@{NSFontAttributeName :self.titleLabel.font}];
    NSInteger lineCount = (size.width / self.frame.size.width) + 1;
    return lineCount;
}

- (void)setShouldShowMoreContent:(BOOL)shouldShowMoreContent
{
    _shouldShowMoreContent = shouldShowMoreContent;
    [self updateView];
}

- (void)updateView
{
    if (_shouldShowMoreContent) {
        CGSize size = [_content sizeWithAttributes:@{NSFontAttributeName :self.titleLabel.font}];
        NSInteger lineCount = (size.width / self.frame.size.width) + 1;
        self.titleLabel.numberOfLines = lineCount;
        self.alpha = 0.6;
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat height = size.height * lineCount;
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y
                                      , self.frame.size.width, height)];
            self.alpha = 1;
        }];
        _resizeHeight = self.frame.size.height - _resetFrame.size.height;
    } else {
        self.alpha = 0.6;
        self.titleLabel.numberOfLines = _numberOfLine;
        [UIView animateWithDuration:0.3 animations:^{
            [self setFrame:_resetFrame];
            self.alpha = 1;
        }];
    }
}

- (void)showMoreContent
{
    self.shouldShowMoreContent = YES;
}

- (void)hideContent
{
    self.shouldShowMoreContent = NO;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _resetFrame = frame;
        self.layer.cornerRadius = 2.0;
        self.titleLabel.numberOfLines = 2;
        self.userInteractionEnabled = NO;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return self;
}

@end




