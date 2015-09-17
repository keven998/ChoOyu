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
        _locationImageView.contentMode = UIViewContentModeScaleAspectFill;
        _locationImageView.backgroundColor = APP_PAGE_COLOR;
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
    if (_model.isSender) {
        _addressLabel.frame = CGRectMake(0, self.locationImageView.frame.size.height - 30, self.locationImageView.frame.size.width, 30);
    } else {
        _addressLabel.frame = CGRectMake(5, self.locationImageView.frame.size.height - 30, self.locationImageView.frame.size.width, 30);
    }
    
    
    UIImage *image = _model.image;
    NSString *maskImageName = _model.isSender ? @"SenderImageNodeBorder_black.png" : @"ReceiverImageNodeBorder_black.png";
    if (!image) {
        image = _model.image;
        if (!image) {
            image = [UIImage imageNamed:LOCATION_IMAGE];
        }
    }
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    maskLayer.strokeColor = [UIColor redColor].CGColor;
    maskLayer.frame = _locationImageView.bounds;
    maskLayer.contents = (id)[UIImage imageNamed:maskImageName].CGImage;
    maskLayer.contentsCenter = CGRectMake(0.5, 0.8, 0.1, 0.1);
    maskLayer.contentsScale = [UIScreen mainScreen].scale;
    
    CALayer *shapedLayer = [CALayer layer];
    shapedLayer.mask = maskLayer;
    shapedLayer.contents = (id)image.CGImage;
    shapedLayer.frame = _locationImageView.frame;
    _locationImageView.layer.mask = maskLayer;
    _locationImageView.layer.masksToBounds = YES;
    self.locationImageView.image = image;
}

#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    _model = model;
    [self setNeedsLayout];

    _addressLabel.text = [NSString stringWithFormat:@" %@ ", _model.address];
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
