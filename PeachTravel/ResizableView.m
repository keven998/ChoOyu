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
    self.text = _content;
}

- (void)setShouldShowMoreContent:(BOOL)shouldShowMoreContent
{
    _shouldShowMoreContent = shouldShowMoreContent;
    [self updateView];
}

- (void)updateView
{
    if (_shouldShowMoreContent) {
        CGSize size = [_content sizeWithAttributes:@{NSFontAttributeName :self.font}];
        NSInteger lineCount = (size.width / self.frame.size.width) + 1;
        self.backgroundColor = [UIColor grayColor];
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat height = size.height * lineCount + 10;
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y
                                      , self.frame.size.width, height)];
            self.alpha = 1;
            self.numberOfLines = lineCount;
        }];

    } else {
        self.alpha = 0;
        self.backgroundColor = [UIColor whiteColor];
        [UIView animateWithDuration:0.3 animations:^{
            [self setFrame:_resetFrame];
            self.numberOfLines = 2;
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
        self.numberOfLines = 2;
    }
    return self;
}

@end




