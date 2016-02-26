//
//  ChatUserCouponBubbleView.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "ChatUserCouponBubbleView.h"

#define  ChatUserCouponBubbleHeight 80
#define  ChatUserCouponBubbleWidth 220

NSString *const kRouterEventChatUserCouponBubbleTapEventName = @"kRouterEventChatUserCouponBubbleTapEventName";

@interface ChatUserCouponBubbleView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *pictureImageView;

@end

@implementation ChatUserCouponBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.numberOfLines = 0;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textColor = COLOR_PRICE_RED;
        
        _pictureImageView = [[UIImageView alloc] init];
        
        [self addSubview:_pictureImageView];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat titleWidth;
    if (_model.isSender) {
        titleWidth = 125;
    } else {
        titleWidth = 135;
    }
    
    if (_model.isSender) {
        [_pictureImageView setFrame:CGRectMake(12.5, 15, 45, 50)];
    } else {
        [_pictureImageView setFrame:CGRectMake(20, 15, 45, 50)];
    }
    
    [_titleLabel setFrame:CGRectMake(_pictureImageView.frame.origin.x + 55, 10, titleWidth, 60)];
    
}

- (void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventChatUserCouponBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model}];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(ChatUserCouponBubbleWidth, ChatUserCouponBubbleHeight);
}

- (void)setModel:(MessageModel *)model
{
    _model = model;
    BOOL isReceiver = !_model.isSender;
    NSString *imageName = isReceiver ? @"messages_poi_bg_friend.png" : @"messages_poi_bg_self.png";
    self.backImageView.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 18, 18, 10)];
    UserCouponMessage *message = (UserCouponMessage *)model.baseMessage;
    [_pictureImageView setImage:[UIImage imageNamed:@"icon_coupons_hongbao"]];
    _titleLabel.text = message.title;
}

/**
 *  得到气泡的高度，因为高度是写死的所以这里直接返回定义的高度
 *
 *  @param object
 *
 *  @return
 */
+ (CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    return ChatUserCouponBubbleHeight;
}


@end
