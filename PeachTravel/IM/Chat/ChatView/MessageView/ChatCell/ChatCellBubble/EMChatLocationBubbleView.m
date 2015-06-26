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

#import "EMChatLocationBubbleView.h"
#import "UIImage+Utils.h"

#define bubbleHeight 120 //
#define bubbleWidth 180 //

NSString *const kRouterEventLocationBubbleTapEventName = @"kRouterEventLocationBubbleTapEventName";

@interface EMChatLocationBubbleView ()

@property (nonatomic, strong) UIImageView *locationImageView;
@property (nonatomic, strong) UILabel *addressLabel;

@end

@implementation EMChatLocationBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self addSubview:_locationImageView];
        
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = [UIFont systemFontOfSize:LOCATION_ADDRESS_LABEL_FONT_SIZE];
        _addressLabel.textColor = [UIColor whiteColor];
        _addressLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _addressLabel.numberOfLines = 0;
        _locationImageView.layer.cornerRadius = 5.0;
        _locationImageView.clipsToBounds = YES;
        [_locationImageView addSubview:_addressLabel];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize textBlockMinSize = {180, 25};
    return CGSizeMake(textBlockMinSize.width + BUBBLE_ARROW_WIDTH, LOCATION_IMAGEVIEW_SIZE);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, 0, 0);
    if (self.model.isSender) {
        frame.origin.x = self.bounds.size.width - bubbleWidth - BUBBLE_ARROW_WIDTH;

    }else{
        frame.origin.x = 0;

    }
    
    frame.origin.y = 0;
    [self.locationImageView setFrame:frame];

    _addressLabel.frame = CGRectMake(0, self.locationImageView.frame.size.height - 30, self.locationImageView.frame.size.width, 30);
}

#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    _model = model;
    
    _addressLabel.text = [NSString stringWithFormat:@" %@ ", _model.address];
    
    UIImage *image = _model.isSender ? _model.image : _model.thumbnailImage;
    NSString *maskImageName = _model.isSender ? @"SenderImageNodeBorder_black.png" : @"ReceiverImageNodeBorder_black.png";
    if (!image) {
        image = _model.image;
        if (!image) {
            image = [UIImage imageNamed:LOCATION_IMAGE];
        }
    }
    CGSize retSize = CGSizeMake(bubbleWidth, bubbleHeight);
    BOOL isReceiver = !_model.isSender;
    NSInteger leftCapWidth = isReceiver?BUBBLE_LEFT_LEFT_CAP_WIDTH:BUBBLE_RIGHT_LEFT_CAP_WIDTH;
    NSInteger rightCapWidth = isReceiver?BUBBLE_RIGHT_LEFT_CAP_WIDTH:BUBBLE_LEFT_LEFT_CAP_WIDTH;
    
    NSInteger topCapHeight =  28;
    UIImage *resizableMaskImage = [UIImage imageNamed:maskImageName];
    resizableMaskImage= [resizableMaskImage resizableImageWithCapInsets:UIEdgeInsetsMake(topCapHeight, leftCapWidth, 10, rightCapWidth)];
    
    UIGraphicsBeginImageContextWithOptions(retSize, NO, 0.0);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), NO);
    [resizableMaskImage drawInRect:CGRectMake(0.5, 0.5, retSize.width, retSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[newImage CGImage];
    mask.frame = CGRectMake(0, 0, retSize.width, retSize.height);
    self.locationImageView.layer.mask = mask;
    self.locationImageView.layer.masksToBounds = YES;
    self.locationImageView.image = image;
}

#pragma mark - public

- (void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventLocationBubbleTapEventName userInfo:@{KMESSAGEKEY:self.model}];
}

+ (CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    return 2 * BUBBLE_VIEW_PADDING + bubbleHeight;
}
@end
