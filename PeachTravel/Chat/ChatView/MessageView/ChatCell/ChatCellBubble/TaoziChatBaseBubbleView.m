//
//  TaoziChatBaseBubbleView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/3/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TaoziChatBaseBubbleView.h"
#import "MessageModel.h"

#define TaoziBubbleHeight   91.0
#define TaoziBubbleWidth    181.0

//类型标题的高度
#define TaoziBubbleTypeHeight    16.5

NSString *const kRouterEventTaoziBubbleTapEventName = @"kRouterEventTaoziBubbleTapEventName";

@interface TaoziChatBaseBubbleView ()

@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIImageView *pictureImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *propertyBtn;
@property (nonatomic, strong) UILabel *descLabel;
@end

@implementation TaoziChatBaseBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.font = [UIFont systemFontOfSize:10.0];
        _typeLabel.textColor = [UIColor whiteColor];
        _typeLabel.backgroundColor = [UIColor clearColor];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        _pictureImageView = [[UIImageView alloc] init];
        _pictureImageView.layer.cornerRadius = 2.0;
        _pictureImageView.clipsToBounds = YES;
        
        _propertyBtn = [[UIButton alloc] init];
        [_propertyBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _propertyBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
        _propertyBtn.userInteractionEnabled = NO;
        _propertyBtn.backgroundColor = [UIColor clearColor];
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:10.0];
        _descLabel.textColor = [UIColor lightGrayColor];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.numberOfLines = 2;
        
        [self addSubview:_typeLabel];
        [self addSubview:_titleLabel];
        [self addSubview:_propertyBtn];
        [self addSubview:_pictureImageView];
        [self addSubview:_descLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_typeLabel setFrame:CGRectMake(BUBBLE_ARROW_WIDTH+8, 0, TaoziBubbleWidth-16-BUBBLE_ARROW_WIDTH-10, TaoziBubbleTypeHeight)];

    if (_model.isSender) {
        _typeLabel.textAlignment = NSTextAlignmentRight;
        _titleLabel.textAlignment = NSTextAlignmentRight;
        _propertyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _descLabel.textAlignment = NSTextAlignmentRight;
        [_pictureImageView setFrame:CGRectMake(TaoziBubbleWidth - 40 - 8 -BUBBLE_ARROW_WIDTH, 4+TaoziBubbleTypeHeight, 40, 40)];
        [_titleLabel setFrame:CGRectMake(8, _pictureImageView.frame.origin.y, TaoziBubbleWidth - 56 - 8 - BUBBLE_ARROW_WIDTH, 20)];
        [_propertyBtn setFrame:CGRectMake(8, _pictureImageView.frame.origin.y+20, TaoziBubbleWidth - 56 - 8 - BUBBLE_ARROW_WIDTH, 20)];
        [_descLabel setFrame:CGRectMake(8, _pictureImageView.frame.origin.y+40, TaoziBubbleWidth-16-BUBBLE_ARROW_WIDTH, 27)];

    } else {
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _propertyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _descLabel.textAlignment = NSTextAlignmentLeft;

        [_pictureImageView setFrame:CGRectMake(BUBBLE_ARROW_WIDTH+8, 4+TaoziBubbleTypeHeight, 40, 40)];
        [_titleLabel setFrame:CGRectMake(_pictureImageView.frame.origin.x+48, _pictureImageView.frame.origin.y, TaoziBubbleWidth - 8 - _pictureImageView.frame.origin.x - 40, 20)];
        [_propertyBtn setFrame:CGRectMake(_titleLabel.frame.origin.x, _pictureImageView.frame.origin.y+20, _titleLabel.frame.size.width, 20)];
        [_descLabel setFrame:CGRectMake(8+BUBBLE_ARROW_WIDTH, _pictureImageView.frame.origin.y+40, TaoziBubbleWidth-16-BUBBLE_ARROW_WIDTH, 27)];

    }
    
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(TaoziBubbleWidth, TaoziBubbleHeight);
}

- (void)setModel:(MessageModel *)model
{
    _model = model;
    
    BOOL isReceiver = !_model.isSender;
    NSString *imageName = isReceiver ? @"message_taozi_receive" : @"message_taozi_send";
    NSInteger leftCapWidth = isReceiver?BUBBLE_LEFT_LEFT_CAP_WIDTH:BUBBLE_RIGHT_LEFT_CAP_WIDTH;
    NSInteger topCapHeight =  17;
    self.backImageView.image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    
    if (model.taoziMessage) {
        NSDictionary *content = [model.taoziMessage objectForKey:@"content"];
        _titleLabel.text = [content objectForKey:@"name"];
        [_pictureImageView sd_setImageWithURL:[NSURL URLWithString:[content objectForKey:@"image"]] placeholderImage:nil];
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
                [_propertyBtn setImage:[UIImage imageNamed:@"rating_star.png"] forState:UIControlStateNormal];
                [_propertyBtn setTitle:protertyStr forState:UIControlStateNormal];
                _descLabel.text = [content objectForKey:@"address"];
            }
                break;
                
            case TZChatTypeHotel: {
                _typeLabel.text = @"酒店";
                [_propertyBtn setImage:[UIImage imageNamed:@"rating_star.png"] forState:UIControlStateNormal];
                NSString *protertyStr = [NSString stringWithFormat:@"%@  %@", [content objectForKey:@"rating"], [content objectForKey:@"price"]];
                [_propertyBtn setTitle:protertyStr forState:UIControlStateNormal];
                _descLabel.text = [content objectForKey:@"address"];
            }
                
                break;
                
            case TZChatTypeShopping:
                _typeLabel.text = @"购物";
                [_propertyBtn setImage:[UIImage imageNamed:@"rating_star.png"] forState:UIControlStateNormal];
                [_propertyBtn setTitle:[content objectForKey:@"rating"] forState:UIControlStateNormal];
                _descLabel.text = [content objectForKey:@"address"];
                
                break;
                
            case TZChatTypeStrategy:
                _typeLabel.text = @"攻略";
                [_propertyBtn setImage:nil forState:UIControlStateNormal];
                [_propertyBtn setTitle:[content objectForKey:@"timeCost"] forState:UIControlStateNormal];
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
