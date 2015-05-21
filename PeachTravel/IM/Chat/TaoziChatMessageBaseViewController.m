//
//  TaoziChatMessageBaseViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/2/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TaoziChatMessageBaseViewController.h"
#import "ChatSendHelper.h"

@interface TaoziChatMessageBaseViewController ()
@property (weak, nonatomic) IBOutlet UIView *imageBkgView;

@end

@implementation TaoziChatMessageBaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = 4.0;
    _sendBtn.layer.cornerRadius = 2.0;
    _cancelBtn.layer.cornerRadius = 2.0;
    _sendBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
    _cancelBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
    _sendBtn.layer.borderWidth = 1.0;
    _cancelBtn.layer.borderWidth = 1.0;
    _headerImageView.layer.cornerRadius = 2.0;
    _headerImageView.clipsToBounds = YES;
    _imageBkgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    _headerImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [_titleBtn setTitle:_messageName forState:UIControlStateNormal];
    if (_messageType == TZChatTypeTravelNote) {
        _titleBtn.titleLabel.numberOfLines = 2;
        _propertyBtn.hidden = YES;

    } else {
        _titleBtn.titleLabel.numberOfLines = 1;
        _propertyBtn.hidden = NO;
    }
    
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_messageImage] placeholderImage:nil];
    
    switch (_messageType) {
        case TZChatTypeSpot:
            _headerLabel.text = @"  景点";
            [_propertyBtn setTitle:_messageTimeCost forState:UIControlStateNormal];
            if ([_messageTimeCost isBlankString] || !_messageTimeCost) {
                [_propertyBtn setImage:nil forState:UIControlStateNormal];
            } else {
                [_propertyBtn setImage:[UIImage imageNamed:@"ic_time.png"] forState:UIControlStateNormal];
            }
            _descLabel.text = _messageDesc;
            
            break;
            
        case TZChatTypeStrategy:
            [_propertyBtn setImage:[UIImage imageNamed:@"ic_time.png"] forState:UIControlStateNormal];
            _headerLabel.text = @"  计划";
            [_propertyBtn setTitle:_messageTimeCost forState:UIControlStateNormal];

            _descLabel.text = _messageDesc;
            break;
            
        case TZChatTypeFood: {
            _headerLabel.text = @"   美食";
            [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_yellow.png"] forState:UIControlStateNormal];
            NSString *propertyStr = [NSString stringWithFormat:@"%.1f  %@",_messageRating, _messagePrice];
            _descLabel.text = _messageAddress;
            [_propertyBtn setTitle:propertyStr forState:UIControlStateNormal];

        }
            break;
            
        case TZChatTypeHotel: {
            _headerLabel.text = @"   酒店";
            [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_yellow.png"] forState:UIControlStateNormal];
            NSString *propertyStr = [NSString stringWithFormat:@"%.1f  %@",_messageRating, _messagePrice];
            _descLabel.text = _messageAddress;
            [_propertyBtn setTitle:propertyStr forState:UIControlStateNormal];
        }
            
            break;
            
        case TZChatTypeShopping: {
            _headerLabel.text = @"   购物";
            [_propertyBtn setImage:[UIImage imageNamed:@"ic_star_yellow.png"] forState:UIControlStateNormal];
            NSString *propertyStr = [NSString stringWithFormat:@"%.1f",_messageRating];
            _descLabel.text = _messageAddress;
            [_propertyBtn setTitle:propertyStr forState:UIControlStateNormal];

        }
            
            break;
            
        case TZChatTypeCity:
            _headerLabel.text = @"   城市";
            if ([_messageTimeCost isBlankString] || !_messageTimeCost) {
                [_propertyBtn setImage:nil forState:UIControlStateNormal];
            } else {
                [_propertyBtn setImage:[UIImage imageNamed:@"ic_time.png"] forState:UIControlStateNormal];
            }
            [_propertyBtn setTitle:_messageTimeCost forState:UIControlStateNormal];
            _descLabel.text = _messageDesc;
            break;
            
        case TZChatTypeTravelNote:
            _headerLabel.text = @"   游记";
            _descLabel.text = _messageDesc;
            break;
            
            
        default:
            break;
    }

}

- (void)setMessageAddress:(NSString *)messageAddress
{
    _messageAddress = messageAddress;
}

- (void)setMessageDesc:(NSString *)messageDesc
{
    _messageDesc = messageDesc;
}

- (void)setMessageName:(NSString *)messageName
{
    _messageName = messageName;
}

- (void)setMessageDetailUrl:(NSString *)messageDetailUrl
{
    _messageDetailUrl = messageDetailUrl;
}

- (void)setMessageRating:(float)messageRating
{
    _messageRating = messageRating;
}

- (void)setMessagePrice:(NSString *)messagePrice
{
    _messagePrice = messagePrice;
}

- (void)setMessageImage:(NSString *)messageImage
{
    _messageImage = messageImage;
}

- (void) setMessageTimeCost:(NSString *)messageTimeCost
{
    _messageTimeCost = messageTimeCost;
}

- (IBAction)confirmSend:(UIButton *)sender {
   
    IMClientManager *imclientManager = [IMClientManager shareInstance];
    BaseMessage *message = [imclientManager.messageSendManager sendPoiMessage:[self dataToSend] receiver:_chatterId chatType:_chatType conversationId:nil];  
    [_delegate sendSuccess:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:updateChateViewNoti object:nil userInfo:@{@"message":message}];

}

- (IBAction)cancel:(UIButton *)sender {
    [_delegate sendCancel];
}

/**
 *  得到需要发送到朋友圈的内容
 *
 *  @return 需要发送的内容
 */
- (IMPoiModel *)dataToSend
{
    IMPoiModel *retModel = [[IMPoiModel alloc] init];
    retModel.poiId = _messageId;
    retModel.image = _messageImage;
    retModel.poiName = _messageName;
    
    switch (_messageType) {
        case IMMessageTypeSpotMessageType:
            retModel.desc = _messageDesc;
            retModel.timeCost = _messageTimeCost;
            break;
            
        case IMMessageTypeGuideMessageType:
            retModel.desc = _messageDesc;
            retModel.timeCost = _messageTimeCost;

            break;
            
        case IMMessageTypeRestaurantMessageType:
            retModel.rating = [NSString stringWithFormat:@"%.1f", _messageRating];
            retModel.price = _messagePrice;
            retModel.address = _messageAddress;
            break;
            
        case IMMessageTypeHotelMessageType:
            retModel.rating = [NSString stringWithFormat:@"%.1f", _messageRating];
            retModel.price = _messagePrice;
            retModel.address = _messageAddress;

            break;
            
        case IMMessageTypeShoppingMessageType:
            retModel.rating = [NSString stringWithFormat:@"%.1f", _messageRating];
            retModel.address = _messageAddress;
            break;
            
        case IMMessageTypeCityPoiMessageType:
            retModel.desc = _messageDesc;

            break;
            
        case IMMessageTypeTravelNoteMessageType:
            retModel.desc = _messageDesc;
            retModel.detailUrl = _messageDetailUrl;

            break;
            
        default:
            break;
    }
    
    return retModel;
}





@end
