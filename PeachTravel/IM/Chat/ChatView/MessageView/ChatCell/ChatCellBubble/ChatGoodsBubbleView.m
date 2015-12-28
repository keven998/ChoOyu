//
//  ChatGoodsBubbleView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/8/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "ChatGoodsBubbleView.h"
#import "PeachTravel-swift.h"

#define  ChatGoodsBubbleHeight 80
#define  ChatGoodsBubbleWidth 205
#define  ChatGoodsTitleBubbleHeight    18

NSString *const kRouterEventChatGoodsBubbleTapEventName = @"kRouterEventChatGoodsBubbleTapEventName";

@interface ChatGoodsBubbleView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UIImageView *pictureImageView;

@end

@implementation ChatGoodsBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = COLOR_TEXT_I;
        
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont systemFontOfSize:12.0];
        _priceLabel.textColor = COLOR_TEXT_II;
        
        _pictureImageView = [[UIImageView alloc] init];
        _pictureImageView.layer.cornerRadius = 4.0;
        _pictureImageView.clipsToBounds = YES;
        [self addSubview:_pictureImageView];
        [self addSubview:_titleLabel];
        [self addSubview:_priceLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat titleWidth;
    if (_model.isSender) {
        titleWidth = 100;
    } else {
        titleWidth = 110;
    }
    
    if (_model.isSender) {
        [_pictureImageView setFrame:CGRectMake(12.5, 10, 60, 60)];
    } else {
        [_pictureImageView setFrame:CGRectMake(20, 10, 60, 60)];
    }

    [_titleLabel setFrame:CGRectMake(_pictureImageView.frame.origin.x + 70, 10, titleWidth, 40)];
    
    [_priceLabel setFrame:CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y+42, titleWidth, 20)];

}

- (void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventChatGoodsBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model}];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(ChatGoodsBubbleWidth, ChatGoodsBubbleHeight);
}

- (void)setModel:(MessageModel *)model
{
    _model = model;
    BOOL isReceiver = !_model.isSender;
    NSString *imageName = isReceiver ? @"messages_poi_bg_friend.png" : @"messages_poi_bg_self.png";
    self.backImageView.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 18, 18, 10)];
    GoodsChatMessage *message = (GoodsChatMessage *)model.baseMessage;
    [_pictureImageView sd_setImageWithURL:[NSURL URLWithString:message.imageUrl] placeholderImage:nil];
    _titleLabel.text = [NSString stringWithFormat:@"产品 | %@", message.goodsName];
    _priceLabel.text = [NSString stringWithFormat:@"￥%.1f", message.price];
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
    return ChatGoodsBubbleHeight;
}

@end
