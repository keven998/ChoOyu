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
        _pictureImageView.backgroundColor = APP_PAGE_COLOR;
        _pictureImageView.clipsToBounds = YES;
        
        _propertyBtn = [[UIButton alloc] init];
        [_propertyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _propertyBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:10.0];
        _propertyBtn.userInteractionEnabled = NO;
        _propertyBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _propertyBtn.backgroundColor = [UIColor clearColor];
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:9.0];
        _descLabel.textColor = [UIColor whiteColor];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.numberOfLines = 3;
        
        [self addSubview:_titleBtn];
        [self addSubview:_propertyBtn];
        [self addSubview:_pictureImageView];
        [self addSubview:_descLabel];
        [self addSubview:_typeLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_typeLabel setFrame:CGRectMake(20, 40, 60, 30)];
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
    
    [_pictureImageView setFrame:CGRectMake(20, 10, 60, 60)];
    [_titleBtn setFrame:CGRectMake(_pictureImageView.frame.origin.x + 70, 10, titleWidth, 20)];

    CGFloat offsetY;
    if ([[_model.taoziMessage objectForKey:@"tzType"] integerValue] == TZChatTypeTravelNote
        || [[_model.taoziMessage objectForKey:@"tzType"] integerValue] == TZChatTypeCity) {
        _propertyBtn.hidden = YES;
        _propertyBtn.frame = CGRectZero;
        offsetY = 25;
    } else {
        _propertyBtn.hidden = NO;
        _propertyBtn.frame = CGRectMake(_titleBtn.frame.origin.x, 30, titleWidth, 15);
        offsetY = 40;
    }

    [_descLabel setFrame:CGRectMake(_titleBtn.frame.origin.x,offsetY, titleWidth, TaoziBubbleHeight-offsetY-10)];
    
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(TaoziBubbleWidth, TaoziBubbleHeight);
}

- (void)setModel:(MessageModel *)model
{
    _model = model;
    
    BOOL isReceiver = !_model.isSender;
    NSString *imageName = isReceiver ? @"chat_receiver_bg" : @"chat_sender_bg";
    NSInteger leftCapWidth = isReceiver?BUBBLE_LEFT_LEFT_CAP_WIDTH:BUBBLE_RIGHT_LEFT_CAP_WIDTH;
    NSInteger topCapHeight =  17;
    self.backImageView.image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    
    if (model.taoziMessage) {
        NSDictionary *content = [model.taoziMessage objectForKey:@"content"];
        [_titleBtn setTitle:[content objectForKey:@"name"] forState:UIControlStateNormal];
        [_pictureImageView sd_setImageWithURL:[NSURL URLWithString:[content objectForKey:@"image"]] placeholderImage:nil];
        /**
         *  默认标题一行，但是游记的话是两行
         */
        _titleBtn.titleLabel.numberOfLines = 1;
        switch ([[model.taoziMessage objectForKey:@"tzType"] integerValue]) {
            case TZChatTypeSpot:
                _typeLabel.text = @"景点";
                [_propertyBtn setTitle:[content objectForKey:@"timeCost"] forState:UIControlStateNormal];
                [_propertyBtn setImage:nil forState:UIControlStateNormal];
                _descLabel.text = [content objectForKey:@"desc"];
                break;
                
            case TZChatTypeFood: {
                _typeLabel.text = @"美食";
                NSString *protertyStr = [NSString stringWithFormat:@"%@  %@", [content objectForKey:@"rating"], [content objectForKey:@"price"]];
                [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_yellow.png"] forState:UIControlStateNormal];
                [_propertyBtn setTitle:protertyStr forState:UIControlStateNormal];
                _descLabel.text = [content objectForKey:@"address"];
            }
                break;
                
            case TZChatTypeHotel: {
                _typeLabel.text = @"酒店";
                [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_yellow.png"] forState:UIControlStateNormal];
                NSString *protertyStr = [NSString stringWithFormat:@"%@  %@", [content objectForKey:@"rating"], [content objectForKey:@"price"]];
                [_propertyBtn setTitle:protertyStr forState:UIControlStateNormal];
                _descLabel.text = [content objectForKey:@"address"];
            }
                
                break;
                
            case TZChatTypeShopping:
                _typeLabel.text = @"购物";
                [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_yellow.png"] forState:UIControlStateNormal];
                [_propertyBtn setTitle:[content objectForKey:@"rating"] forState:UIControlStateNormal];
                _descLabel.text = [content objectForKey:@"address"];
                
                break;
                
            case TZChatTypeStrategy:
                _typeLabel.text = @"计划";
                [_propertyBtn setImage:nil forState:UIControlStateNormal];
                [_propertyBtn setTitle:[content objectForKey:@"timeCost"] forState:UIControlStateNormal];
                _descLabel.text = [content objectForKey:@"desc"];
                break;
                
            case TZChatTypeTravelNote:
                _typeLabel.text = @"游记";
                _propertyBtn.hidden = YES;
                _descLabel.text = [content objectForKey:@"desc"];
                break;

            case TZChatTypeCity:
                _typeLabel.text = @"城市";
                _propertyBtn.hidden = YES;
                _descLabel.text = [content objectForKey:@"desc"];
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
