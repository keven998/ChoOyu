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
@property (nonatomic, strong) UIView *pictureImageBkgView;

@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) UIButton *propertyBtn;
@property (nonatomic, strong) UILabel *descLabel;
@end

@implementation TaoziChatBaseBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.font = [UIFont boldSystemFontOfSize:25.0];
        _typeLabel.textColor = [UIColor whiteColor];
        _typeLabel.backgroundColor = [UIColor clearColor];
        
        _titleBtn = [[UIButton alloc] init];
        _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _titleBtn.backgroundColor = [UIColor clearColor];
        _titleBtn.userInteractionEnabled = NO;
        _titleBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _pictureImageView = [[UIImageView alloc] init];
        _pictureImageView.layer.cornerRadius = 2.0;
        _pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        _pictureImageView.clipsToBounds = YES;
        
        _pictureImageBkgView = [[UIView alloc] init];
        _pictureImageBkgView.layer.cornerRadius = 2.0;
        _pictureImageBkgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _pictureImageView.clipsToBounds = YES;
        
        _propertyBtn = [[UIButton alloc] init];
        [_propertyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _propertyBtn.titleLabel.font = [UIFont systemFontOfSize:10.0];
        _propertyBtn.userInteractionEnabled = NO;
        _propertyBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _propertyBtn.backgroundColor = [UIColor clearColor];
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:9.0];
        _descLabel.textColor = [UIColor whiteColor];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.numberOfLines = 3;
        
        [self addSubview:_titleBtn];
        [self addSubview:_propertyBtn];
        [self addSubview:_pictureImageView];
        [self addSubview:_pictureImageBkgView];
        [self addSubview:_descLabel];
        [self addSubview:_typeLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_model.isSender) {
        [_typeLabel setFrame:CGRectMake(12.5, 40, 60, 30)];
    } else {
        [_typeLabel setFrame:CGRectMake(20, 40, 60, 30)];
    }
    _titleBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _typeLabel.textAlignment = NSTextAlignmentRight;
    _titleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _propertyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _descLabel.textAlignment = NSTextAlignmentLeft;
    
    CGFloat titleWidth;
    if (_model.isSender) {
        _descLabel.textColor = [UIColor whiteColor];
        [_propertyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        titleWidth = 100;
    } else {
        titleWidth = 110;
        _descLabel.textColor = TEXT_COLOR_TITLE;
        [_propertyBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
        [_titleBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    }
    if (_model.isSender) {
        [_pictureImageView setFrame:CGRectMake(12.5, 10, 60, 60)];
        [_pictureImageBkgView setFrame:CGRectMake(12.5,
                                                  
                                                  
                                                  10, 60, 60)];
    } else {
        [_pictureImageView setFrame:CGRectMake(20, 10, 60, 60)];
        [_pictureImageBkgView setFrame:CGRectMake(20, 10, 60, 60)];
    }
    
    [_titleBtn setFrame:CGRectMake(_pictureImageView.frame.origin.x + 70, 10, titleWidth, 20)];
    
    CGFloat offsetY;
    if (_model.type ==  IMMessageTypeTravelNoteMessageType
        || _model.type == IMMessageTypeCityPoiMessageType) {
        _propertyBtn.hidden = YES;
        _propertyBtn.frame = CGRectZero;
        offsetY = 25;
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
    NSString *imageName = isReceiver ? @"messages_bg_friend.png" : @"messages_bg_self.png";
    NSInteger leftCapWidth = isReceiver ? BUBBLE_LEFT_LEFT_CAP_WIDTH : BUBBLE_RIGHT_LEFT_CAP_WIDTH;
    NSInteger topCapHeight = 25;
    //    self.backImageView.image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    self.backImageView.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(leftCapWidth, leftCapWidth, topCapHeight, 2*leftCapWidth)];
    
    if (model.poiModel) {
        [_titleBtn setTitle:model.poiModel.poiName forState:UIControlStateNormal];
        [_pictureImageView sd_setImageWithURL:[NSURL URLWithString:model.poiModel.image] placeholderImage:nil];
        /**
         *  默认标题一行，但是游记的话是两行
         */
        _titleBtn.titleLabel.numberOfLines = 1;
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
        
    }
}

-(void)bubbleViewPressed:(id)sender
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
