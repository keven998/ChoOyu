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
        _addressLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:LOCATION_ADDRESS_LABEL_FONT_SIZE];
        _addressLabel.textColor = [UIColor whiteColor];
        _addressLabel.numberOfLines = 0;
        _addressLabel.backgroundColor = [UIColor clearColor];
        [_locationImageView addSubview:_addressLabel];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize textBlockMinSize = {130, 25};
    
    CGSize addressSize = [self.model.address boundingRectWithSize:textBlockMinSize options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName: _addressLabel.font} context:nil].size;
    
    CGFloat width = addressSize.width < LOCATION_IMAGEVIEW_SIZE ? LOCATION_IMAGEVIEW_SIZE : addressSize.width-BUBBLE_ARROW_WIDTH;
    
    return CGSizeMake(width + BUBBLE_ARROW_WIDTH, LOCATION_IMAGEVIEW_SIZE);
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
    
    frame.origin.y = 0;
    [self.locationImageView setFrame:frame];
    _addressLabel.frame = CGRectMake(5, self.locationImageView.frame.size.height - 30, self.locationImageView.frame.size.width - 20, 25);
}

#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    [super setModel:model];
    
    NSString *maskImageName = _model.isSender ? @"SenderImageNodeBorder_back.png" : @"ReceiverImageNodeBorder_back.png";
    _addressLabel.text = model.address;

    [self resizeImage:[UIImage imageNamed:LOCATION_IMAGE] withMaskImageName:maskImageName];
}

- (void) resizeImage:(UIImage *)image withMaskImageName:(NSString *)maskImageName;
{
    const UIImage *resizableMaskImage = [[UIImage imageNamed:maskImageName] stretchableImageWithLeftCapWidth:15 topCapHeight:30];
    CGSize size = CGSizeMake(100, 150);
    const UIImage *maskImageDrawnToSize = [resizableMaskImage renderAtSize:size];
    _locationImageView.image = [image maskWithImage: maskImageDrawnToSize];
    
}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventLocationBubbleTapEventName userInfo:@{KMESSAGEKEY:self.model}];
}

+(CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    return 2 * BUBBLE_VIEW_PADDING + LOCATION_IMAGEVIEW_SIZE;
}
@end