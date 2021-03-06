//
//  TaoziChatMessageBaseViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/2/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TaoziChatMessageBaseViewController.h"

@interface TaoziChatMessageBaseViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *imageBkgView;

@end

@implementation TaoziChatMessageBaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = 8.0;

    // 设置字体颜色以及宽度
    _headerLabel.textColor = APP_THEME_COLOR;
    _sendBtn.layer.borderColor = COLOR_LINE.CGColor;
    _cancelBtn.layer.borderColor = COLOR_LINE.CGColor;
    _sendBtn.layer.borderWidth = 1.0;
    _cancelBtn.layer.borderWidth = 1.0;
    _headerImageView.layer.cornerRadius = 2.0;
    _headerImageView.clipsToBounds = YES;
    [_sendBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_titleBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    _imageBkgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    _headerImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [_titleBtn setTitle:_messageName forState:UIControlStateNormal];
    if (_messageType == IMMessageTypeTravelNoteMessageType) {
        _titleBtn.titleLabel.numberOfLines = 2;
        _propertyBtn.hidden = YES;

    } else {
        _titleBtn.titleLabel.numberOfLines = 1;
        _propertyBtn.hidden = NO;
    }
    
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_messageImage] placeholderImage:nil];
    
    switch (_messageType) {
        case IMMessageTypeSpotMessageType:
            _headerLabel.text = @"  景点";
            [_propertyBtn setTitle:_messageTimeCost forState:UIControlStateNormal];
            if ([_messageTimeCost isBlankString] || !_messageTimeCost) {
                [_propertyBtn setImage:nil forState:UIControlStateNormal];
            } else {
                [_propertyBtn setImage:[UIImage imageNamed:@"poi_clock_default.png"] forState:UIControlStateNormal];
            }
            _descLabel.text = _messageDesc;
            
            break;
            
        case IMMessageTypeGuideMessageType:
            [_propertyBtn setImage:[UIImage imageNamed:@"poi_clock_default.png"] forState:UIControlStateNormal];
            _headerLabel.text = @"  计划";
            [_propertyBtn setTitle:_messageTimeCost forState:UIControlStateNormal];

            _descLabel.text = _messageDesc;
            break;
            
        case IMMessageTypeRestaurantMessageType: {
            _headerLabel.text = @"   美食";
            [_propertyBtn setImage:[UIImage imageNamed:@"poi_comment_start_highlight.png"] forState:UIControlStateNormal];
            NSString *propertyStr = [NSString stringWithFormat:@"%.1f  %@",_messageRating, _messagePrice];
            _descLabel.text = _messageAddress;
            [_propertyBtn setTitle:propertyStr forState:UIControlStateNormal];

        }
            break;
            
        case IMMessageTypeHotelMessageType: {
            _headerLabel.text = @"   酒店";
            [_propertyBtn setImage:[UIImage imageNamed:@"poi_comment_start_highlight.png"] forState:UIControlStateNormal];
            NSString *propertyStr = [NSString stringWithFormat:@"%.1f  %@",_messageRating, _messagePrice];
            _descLabel.text = _messageAddress;
            [_propertyBtn setTitle:propertyStr forState:UIControlStateNormal];
        }
            
            break;
            
        case IMMessageTypeShoppingMessageType: {
            _headerLabel.text = @"   购物";
            [_propertyBtn setImage:[UIImage imageNamed:@"poi_comment_start_highlight.png"] forState:UIControlStateNormal];
            NSString *propertyStr = [NSString stringWithFormat:@"%.1f",_messageRating];
            _descLabel.text = _messageAddress;
            [_propertyBtn setTitle:propertyStr forState:UIControlStateNormal];

        }
            break;
            
        case IMMessageTypeCityPoiMessageType:
            _headerLabel.text = @"   城市";
            if ([_messageTimeCost isBlankString] || !_messageTimeCost) {
                [_propertyBtn setImage:nil forState:UIControlStateNormal];
            } else {
                [_propertyBtn setImage:[UIImage imageNamed:@"poi_clock_default.png"] forState:UIControlStateNormal];
            }
            [_propertyBtn setTitle:_messageTimeCost forState:UIControlStateNormal];
            _descLabel.text = _messageDesc;
            break;
            
        case IMMessageTypeTravelNoteMessageType:
            _headerLabel.text = @"   游记";
            _descLabel.text = _messageDesc;
            break;
            
            
        default:
            break;
    }

    // 监听键盘的变化
    self.messageText.layer.borderColor = UIColorFromRGB(0xe2e2e2).CGColor;
    self.messageText.layer.borderWidth = 1.0;
    self.messageText.delegate = self;
}

#pragma mark - 监听键盘的高度变化
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"%s",__func__);
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, -150);
    }];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformIdentity;
    }];

    return YES;
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

// 留言信息
- (void)setMessageText:(UITextField *)messageText
{
    _messageText = messageText;
}

#pragma mark - 监听键盘改变

- (IBAction)confirmSend:(UIButton *)sender {
    IMClientManager *imclientManager = [IMClientManager shareInstance];
    
    // 发送Poi消息
    BaseMessage *message = [imclientManager.messageSendManager sendPoiMessage:[self dataToSend] receiver:_chatterId chatType:_chatType conversationId:nil completionBlock:^(BOOL isSuccess, NSString * __nullable error) {
        if (!isSuccess) {
            if (error) {
                TipsMessage *message = [[TipsMessage alloc] initWithContent:error tipsType:TipsMessageTypeCommon_Tips];
                message.chatterId = _chatterId;
                message.createTime = [[NSDate date] timeIntervalSince1970];
                ChatConversation *conversation = [imclientManager.conversationManager getConversationWithChatterId:_chatterId chatType:_chatType];
                [conversation addReceiveMessage:message];
                [conversation insertMessage2DB:message];
            }
        } else {
            // 发送文本消息
            if (!self.messageText.text.length == 0) {
                BaseMessage * textMessage = [imclientManager.messageSendManager sendTextMessage:self.messageText.text receiver:_chatterId chatType:_chatType conversationId:nil completionBlock:^(BOOL isSuccess, NSString * __nullable errors) {
                    
                }];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateChateViewNoti object:nil userInfo:@{@"message":textMessage}];
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:updateChateViewNoti object:nil userInfo:@{@"message":message}];
    
    [_delegate sendSuccess:nil];
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
            retModel.poiType = IMPoiTypeSpot;
            break;
            
        case IMMessageTypeGuideMessageType:
            retModel.desc = _messageDesc;
            retModel.timeCost = _messageTimeCost;
            retModel.poiType = IMPoiTypeGuide;

            break;
            
        case IMMessageTypeRestaurantMessageType:
            retModel.rating = [NSString stringWithFormat:@"%.1f", _messageRating];
            retModel.price = _messagePrice;
            retModel.address = _messageAddress;
            retModel.poiType = IMPoiTypeRestaurant;

            break;
            
        case IMMessageTypeHotelMessageType:
            retModel.rating = [NSString stringWithFormat:@"%.1f", _messageRating];
            retModel.price = _messagePrice;
            retModel.address = _messageAddress;
            retModel.poiType = IMPoiTypeHotel;

            break;
            
        case IMMessageTypeShoppingMessageType:
            retModel.rating = [NSString stringWithFormat:@"%.1f", _messageRating];
            retModel.address = _messageAddress;
            retModel.poiType = IMPoiTypeShopping;

            break;
            
        case IMMessageTypeCityPoiMessageType:
            retModel.desc = _messageDesc;
            retModel.poiType = IMPoiTypeCity;

            break;
            
        case IMMessageTypeTravelNoteMessageType:
            retModel.desc = _messageDesc;
            retModel.detailUrl = _messageDetailUrl;
            retModel.poiType = IMPoiTypeTravelNote;

            break;
            
        default:
            break;
    }
    
    return retModel;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}



@end
