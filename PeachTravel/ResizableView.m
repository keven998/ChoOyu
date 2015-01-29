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
    [self setAttributedTitle:[_content stringByAddLineSpacingAndTextColor:_contentColor] forState:UIControlStateNormal];
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
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.0;

    CGSize labelSize = [_content boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : _contentFont,
                                                        NSParagraphStyleAttributeName: style
                                                        }
                                              context:nil].size;
    CGFloat heightPerLine = [@"" sizeWithAttributes:@{ NSFontAttributeName : _contentFont}].height;
    NSInteger lineCount = (labelSize.height+1)/heightPerLine;
   
    return lineCount;
}

- (CGFloat)maxHeight
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.0;
    
    CGSize labelSize = [_content boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : _contentFont,
                                                        NSParagraphStyleAttributeName: style
                                                        }
                                              context:nil].size;
    return labelSize.height;
}

- (void)setShouldShowMoreContent:(BOOL)shouldShowMoreContent
{
    _shouldShowMoreContent = shouldShowMoreContent;
    [self updateView];
}

- (void)updateView
{
    if (_shouldShowMoreContent) {
        self.titleLabel.numberOfLines = 0;
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 2.0;
        
        CGSize labelSize = [_content boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{
                                                                   NSFontAttributeName : _contentFont,
                                                                   NSParagraphStyleAttributeName : style
                                                                   }
                                                         context:nil].size;
        
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2 animations:^{
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y
                                      , self.frame.size.width, labelSize.height)];

        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;

        }];
        _resizeHeight = self.frame.size.height - _resetFrame.size.height;


        
    } else {
        self.titleLabel.numberOfLines = _numberOfLine;

        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2 animations:^{
            [self setFrame:_resetFrame];
            
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
            
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

- (instancetype)initWithFrame:(CGRect)frame andNumberOfLine:(NSUInteger)numberOfLine
{
    self = [super initWithFrame:frame];
    if (self) {
        _numberOfLine = numberOfLine;
        _resetFrame = frame;
        self.titleLabel.numberOfLines = _numberOfLine;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 2.0;
    }
    return self;
}

@end




