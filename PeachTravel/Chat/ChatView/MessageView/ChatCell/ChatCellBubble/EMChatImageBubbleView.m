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
    [super setModel:model];
    
    UIImage *image = _model.isSender ? _model.image : _model.thumbnailImage;
    NSString *maskImageName = _model.isSender ? @"SenderImageNodeBorder_back.png" : @"ReceiverImageNodeBorder_back.png";
    if (!image) {
        image = _model.image;
        if (!image) {
            image = [UIImage imageNamed:@"imageDownloadFail.png"];
        }
    }
    [self resizeImage:image withMaskImageName:maskImageName];

}

- (void) resizeImage:(UIImage *)image withMaskImageName:(NSString *)maskImageName;
{
    const UIImage *resizableMaskImage = [[UIImage imageNamed:maskImageName] stretchableImageWithLeftCapWidth:15 topCapHeight:30];
    CGSize size = CGSizeMake(100, 100);
    const UIImage *maskImageDrawnToSize = [resizableMaskImage renderAtSize:size];
    self.imageView.image = [image maskWithImage: maskImageDrawnToSize];

}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventImageBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model}];
}

+(CGFloat)heightForBubbleWithObject:(MessageModel *)object
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
