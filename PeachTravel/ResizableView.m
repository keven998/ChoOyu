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
    [self setTitleColor:contentColor forState:UIControlStateHighlighted];

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
    NSString *handelStr = [_content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    CGSize size = [handelStr sizeWithAttributes:@{NSFontAttributeName :self.titleLabel.font}];
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
        
        NSString *handelStr = [_content stringByReplacingOccurrencesOfString:@"\n" withString:@""];

        CGSize sizeWithoutBread = [handelStr sizeWithAttributes:@{NSFontAttributeName :_contentFont}];
        
        CGSize size = [_content sizeWithAttributes:@{NSFontAttributeName :_contentFont}];
        
        NSLog(@"%d", (int)(size.height/sizeWithoutBread.height));
        
        NSInteger exterCount = size.height/sizeWithoutBread.height;
        
        NSInteger lineCount = (sizeWithoutBread.width / self.frame.size.width) + exterCount;

        NSLog(@"%f", (size.width / self.frame.size.width) );
        
        NSLog(@"%f", self.frame.size.width);
        
        self.titleLabel.numberOfLines = lineCount;

        CGFloat height = sizeWithoutBread.height * lineCount;
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y
                                  , self.frame.size.width, height)];

        _resizeHeight = self.frame.size.height - _resetFrame.size.height;
        
    } else {
        self.titleLabel.numberOfLines = _numberOfLine;

        [self setFrame:_resetFrame];
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

- (instancetype)initWithFrame:(CGRect)frame andNumberOfLine:(NSUInteger)numberOfLine
{
    self = [super initWithFrame:frame];
    if (self) {
        _numberOfLine = numberOfLine;
        _resetFrame = frame;
        self.layer.cornerRadius = 2.0;
        self.titleLabel.numberOfLines = _numberOfLine;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return self;
}

@end




