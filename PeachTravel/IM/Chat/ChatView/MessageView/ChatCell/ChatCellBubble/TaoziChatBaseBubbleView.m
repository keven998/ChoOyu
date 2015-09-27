//
//  TaoziChatBaseBubbleView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/3/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TaoziChatBaseBubbleView.h"
#import "MessageModel.h"

#define TaoziBubbleHeight   80.0
#define TaoziBubbleWidth    205

//类型标题的高度
#define TaoziBubbleTypeHeight    16.5

NSString *const kRouterEventTaoziBubbleTapEventName = @"kRouterEventTaoziBubbleTapEventName";

@interface TaoziChatBaseBubbleView ()

@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIImageView *pictureImageView;

@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) UIButton *propertyBtn;
@property (nonatomic, strong) UILabel *descLabel;
@end

@implementation TaoziChatBaseBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        _typeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _typeLabel.textColor = [UIColor whiteColor];
        _typeLabel.hidden = YES;
        
        _titleBtn = [[UIButton alloc] init];
        _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_titleBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
        _titleBtn.backgroundColor = [UIColor clearColor];
        _titleBtn.userInteractionEnabled = NO;
        _titleBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _pictureImageView = [[UIImageView alloc] init];
        _pictureImageView.layer.cornerRadius = 2.0;
        _pictureImageView.backgroundColor = APP_PAGE_COLOR;
        _pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        _pictureImageView.clipsToBounds = YES;
        
        _propertyBtn = [[UIButton alloc] init];
        [_propertyBtn setTitleColor:COLOR_TEXT_III forState:UIControlStateNormal];
        _propertyBtn.titleLabel.font = [UIFont systemFontOfSize:10.0];
        _propertyBtn.userInteractionEnabled = NO;
        _propertyBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _propertyBtn.backgroundColor = [UIColor clearColor];
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:9.0];
        _descLabel.textColor = COLOR_TEXT_III;
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.numberOfLines = 3;
        
        [self addSubview:_titleBtn];
        [self addSubview:_propertyBtn];
        [self addSubview:_pictureImageView];
        [self addSubview:_descLabel];
        [_pictureImageView addSubview:_typeLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _titleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _propertyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _descLabel.textAlignment = NSTextAlignmentLeft;
    
    CGFloat titleWidth;
    if (_model.isSender) {
        titleWidth = 100;
    } else {
        titleWidth = 110;
    }
    _descLabel.textColor = COLOR_TEXT_III;
    [_propertyBtn setTitleColor:COLOR_TEXT_III forState:UIControlStateNormal];
    [_titleBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    
    if (_model.isSender) {
        [_pictureImageView setFrame:CGRectMake(12.5, 10, 60, 60)];
    } else {
        [_pictureImageView setFrame:CGRectMake(20, 10, 60, 60)];
    }
    
    [_typeLabel setFrame:CGRectMake(0, _pictureImageView.bounds.size.height-24, _pictureImageView.bounds.size.width, 24)];
    
    [_titleBtn setFrame:CGRectMake(_pictureImageView.frame.origin.x + 70, 10, titleWidth, 20)];
    
    CGFloat offsetY;
    if (_model.type ==  IMMessageTypeTravelNoteMessageType || _model.type == IMMessageTypeCityPoiMessageType || _model.type == IMMessageTypeHtml5MessageType) {
        _propertyBtn.hidden = YES;
        _propertyBtn.frame = CGRectZero;
        offsetY = 32;
    } else {
        _propertyBtn.hidden = NO;
        _propertyBtn.frame = CGRectMake(_titleBtn.frame.origin.x, 30, titleWidth, 15);
        offsetY = 40;
    }
    
    [_descLabel setFrame:CGRectMake(_titleBtn.frame.origin.x, offsetY+4, titleWidth, TaoziBubbleHeight-offsetY-10)];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(TaoziBubbleWidth, TaoziBubbleHeight);
}

- (void)setModel:(MessageModel *)model
{
    _model = model;
    
    BOOL isReceiver = !_model.isSender;
    NSString *imageName = isReceiver ? @"messages_poi_bg_friend.png" : @"messages_poi_bg_self.png";
    self.backImageView.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 18, 18, 10)];

    if (model.poiModel) {
        _titleBtn.titleLabel.numberOfLines = 1;
        [_titleBtn setTitle:model.poiModel.poiName forState:UIControlStateNormal];
        [_pictureImageView sd_setImageWithURL:[NSURL URLWithString:model.poiModel.image] placeholderImage:nil];
    
        switch (model.type) {
                
            case IMMessageTypeSpotMessageType:
                _typeLabel.text = @"景点";
                [_propertyBtn setTitle:model.poiModel.timeCost forState:UIControlStateNormal];
                [_propertyBtn setImage:nil forState:UIControlStateNormal];
                _descLabel.text = model.poiModel.desc;
                break;
                
            case IMMessageTypeRestaurantMessageType: {
                _typeLabel.text = @"美食";
                NSString *protertyStr = [NSString stringWithFormat:@"%@  %@", model.poiModel.rating, model.poiModel.price];
                if (_model.isSender) {
                    [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_gray_small.png"] forState:UIControlStateNormal];
                } else {
                    [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_yellow_small.png"] forState:UIControlStateNormal];
                }
                [_propertyBtn setTitle:protertyStr forState:UIControlStateNormal];
                _descLabel.text = model.poiModel.address;
            }
                break;
                
            case IMMessageTypeHotelMessageType: {
                _typeLabel.text = @"酒店";
                if (_model.isSender) {
                    [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_gray_small.png"] forState:UIControlStateNormal];
                } else {
                    [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_yellow_small.png"] forState:UIControlStateNormal];
                }
                NSString *protertyStr = [NSString stringWithFormat:@"%@  %@", model.poiModel.rating, model.poiModel.price];
                [_propertyBtn setTitle:protertyStr forState:UIControlStateNormal];
                _descLabel.text = model.poiModel.address;
            }
                break;
                
            case IMMessageTypeShoppingMessageType:
                _typeLabel.text = @"购物";
                if (_model.isSender) {
                    [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_gray_small.png"] forState:UIControlStateNormal];
                } else {
                    [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_yellow_small.png"] forState:UIControlStateNormal];
                }
                [_propertyBtn setTitle:model.poiModel.rating forState:UIControlStateNormal];
                _descLabel.text = model.poiModel.address;
                break;
                
            case IMMessageTypeGuideMessageType:
                _typeLabel.text = @"计划";
                [_propertyBtn setImage:nil forState:UIControlStateNormal];
                [_propertyBtn setTitle:model.poiModel.timeCost forState:UIControlStateNormal];
                _descLabel.text = model.poiModel.desc;
                break;
                
            case IMMessageTypeTravelNoteMessageType:
                _typeLabel.text = @"游记";
                _propertyBtn.hidden = YES;
                _descLabel.text = model.poiModel.desc;
                break;
                
            case IMMessageTypeCityPoiMessageType:
                _typeLabel.text = @"城市";
                _propertyBtn.hidden = YES;
                _descLabel.text = model.poiModel.desc;
                break;
                
            default:
                break;
        }
        
    } else if (model.type == IMMessageTypeHtml5MessageType) {
        _titleBtn.titleLabel.numberOfLines = 2;
        [_titleBtn setTitle:((HtmlMessage *)model.baseMessage).title forState:UIControlStateNormal];
        [_pictureImageView sd_setImageWithURL:[NSURL URLWithString:((HtmlMessage *)model.baseMessage).imageUrl] placeholderImage:nil];
        _descLabel.text = ((HtmlMessage *)model.baseMessage).subtitle;
    }
}

- (void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventTaoziBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model}];
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
    return TaoziBubbleHeight + 10;
}

@end
