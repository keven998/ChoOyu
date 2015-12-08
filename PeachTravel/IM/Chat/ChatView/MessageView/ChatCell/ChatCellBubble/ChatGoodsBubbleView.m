//
//  ChatGoodsBubbleView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/8/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "ChatGoodsBubbleView.h"
#import "PeachTravel-swift.h"

NSString *const kRouterEventChatGoodsBubbleTapEventName = @"kRouterEventChatGoodsBubbleTapEventName";

@interface ChatGoodsBubbleView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *titleImageView;

@end

@implementation ChatGoodsBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12.0];
        _titleLabel.textColor = [UIColor whiteColor];
        
        _titleImageView = [[UIImageView alloc] init];
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.layer.cornerRadius = 4.0;
        _coverImageView.clipsToBounds = YES;
        [self addSubview:_coverImageView];
        [self addSubview:_titleImageView];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_titleLabel setFrame:CGRectMake(BUBBLE_ARROW_WIDTH+8, 0, ChatGoodsBubbleWidth-16-2*BUBBLE_ARROW_WIDTH, ChatGoodsBubbleHeight)];
    [_titleImageView setFrame:CGRectMake(0, 0, ChatGoodsBubbleWidth, ChatGoodsBubbleHeight)];
    
    if (self.model.isSender) {
        
        [_coverImageView setFrame:CGRectMake(0, 0, ChatGoodsBubbleWidth-BUBBLE_ARROW_WIDTH, ChatGoodsBubbleHeight)];
        _titleLabel.textAlignment = NSTextAlignmentRight;
        
    } else {
        [_coverImageView setFrame:CGRectMake(BUBBLE_ARROW_WIDTH, 0, ChatGoodsBubbleWidth-BUBBLE_ARROW_WIDTH, ChatGoodsBubbleHeight)];
        
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    NSString *imageName = self.model.isSender ? @"messages_poi_bg_self.png" : @"messages_poi_bg_friend.png";
    
    _titleImageView.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 18, 18, 10)];
    
    
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
    GoodsChatMessage *message = (GoodsChatMessage *)model.baseMessage;
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:message.imageUrl] placeholderImage:nil];
    _titleLabel.text = message.goodsName;
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
