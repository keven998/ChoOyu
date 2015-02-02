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

#import <SDWebImage/UIImageView+WebCache.h>
#import "EMChatImageBubbleView.h"
#import "UIImage+Utils.h"

NSString *const kRouterEventImageBubbleTapEventName = @"kRouterEventImageBubbleTapEventName";

@interface EMChatImageBubbleView ()

@end

@implementation EMChatImageBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize retSize = self.model.size;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    
    return CGSizeMake(retSize.width + BUBBLE_ARROW_WIDTH, retSize.height);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, 0, 0);
    if (self.model.isSender) {
        frame.origin.x = 0;
    }else{
        frame.origin.x = BUBBLE_ARROW_WIDTH;
    }
    
    [self.imageView setFrame:frame];
}

#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    _model = model;
    
    UIImage *image = _model.isSender ? _model.image : _model.thumbnailImage;
    NSString *maskImageName = _model.isSender ? @"SenderImageNodeBorder_back.png" : @"ReceiverImageNodeBorder_back.png";
    if (!image) {
        image = _model.image;
        if (!image) {
            image = [UIImage imageNamed:@"imageDownloadFail.png"];
        }
    }
    CGSize retSize = model.size;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    } else if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    } else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    
    BOOL isReceiver = !_model.isSender;
    NSInteger leftCapWidth = isReceiver?BUBBLE_LEFT_LEFT_CAP_WIDTH:BUBBLE_RIGHT_LEFT_CAP_WIDTH;
    NSInteger rightCapWidth = isReceiver?BUBBLE_RIGHT_LEFT_CAP_WIDTH:BUBBLE_LEFT_LEFT_CAP_WIDTH;
    
    NSInteger topCapHeight =  isReceiver?BUBBLE_LEFT_TOP_CAP_HEIGHT:BUBBLE_RIGHT_TOP_CAP_HEIGHT;
    UIImage *resizableMaskImage = [UIImage imageNamed:maskImageName];
    resizableMaskImage= [resizableMaskImage resizableImageWithCapInsets:UIEdgeInsetsMake(topCapHeight, leftCapWidth, 10, rightCapWidth)];
    
    UIGraphicsBeginImageContextWithOptions(retSize, NO, 0.0);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), NO);
    [resizableMaskImage drawInRect:CGRectMake(0, 0, retSize.width, retSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[newImage CGImage];
    mask.frame = CGRectMake(0, 0, retSize.width, retSize.height);
    self.imageView.layer.mask = mask;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.image = image;
}

#pragma mark - public

- (void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventImageBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model,
                                @"imageView":self.imageView
                                }];
}

+ (CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    CGSize retSize = object.size;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }else if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    return 2 * BUBBLE_VIEW_PADDING + retSize.height;
}

@end
