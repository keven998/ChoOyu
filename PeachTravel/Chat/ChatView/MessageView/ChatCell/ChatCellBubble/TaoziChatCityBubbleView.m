//
//  TaoziChatCityBubbleView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/8/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TaoziChatCityBubbleView.h"

NSString *const kRouterEventTaoziCityBubbleTapEventName = @"kRouterEventTaoziCityBubbleTapEventName";

@interface TaoziChatCityBubbleView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *titleImageView;

@end

@implementation TaoziChatCityBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];
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
    
    [_titleLabel setFrame:CGRectMake(BUBBLE_ARROW_WIDTH+8, 0, TaoziCityBubbleWidth-16-2*BUBBLE_ARROW_WIDTH, TaoziCityTitleBubbleHeight)];
    [_titleImageView setFrame:CGRectMake(0, 0, TaoziCityBubbleWidth, TaoziCityTitleBubbleHeight)];

    if (self.model.isSender) {
        
        [_coverImageView setFrame:CGRectMake(0, 0, TaoziCityBubbleWidth-BUBBLE_ARROW_WIDTH, TaoziCityBubbleHeight)];
        _titleLabel.textAlignment = NSTextAlignmentRight;
        _titleImageView.image = [[UIImage imageNamed:@"message_taozi_city_send.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    } else {
        [_coverImageView setFrame:CGRectMake(BUBBLE_ARROW_WIDTH, 0, TaoziCityBubbleWidth-BUBBLE_ARROW_WIDTH, TaoziCityBubbleHeight)];

        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleImageView.image = [[UIImage imageNamed:@"message_taozi_city_receive.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
    }
    
}

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventTaoziCityBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model}];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(TaoziCityBubbleWidth, TaoziCityBubbleHeight);
}

- (void)setModel:(MessageModel *)model
{
    _model = model;
    NSDictionary *content = [model.taoziMessage objectForKey:@"content"];
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:[content objectForKey:@"image"]] placeholderImage:nil];
    _titleLabel.text = [content objectForKey:@"name"];
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
    return TaoziCityBubbleHeight + 10;
}

@end
