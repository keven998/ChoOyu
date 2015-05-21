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
   
//    ChatViewController *temtChatCtl = [[ChatViewController alloc] initWithChatter:_chatterId isGroup:_isGroup];
//    ChatViewController *temp
//    temtChatCtl.title = _chatTitle;
//    EMMessage *message = [ChatSendHelper sendTaoziMessageWithString:@"" andExtMessage:[self dataToSend] toUsername:_chatter isChatGroup:_isGroup requireEncryption:NO];
//    
//    [_delegate sendSuccess:temtChatCtl];
//    [[NSNotificationCenter defaultCenter] postNotificationName:updateChateViewNoti object:nil userInfo:@{@"message":message}];

}

- (IBAction)cancel:(UIButton *)sender {
    [_delegate sendCancel];
}

/**
 *  得到需要发送到朋友圈的内容
 *
 *  @return 需要发送的内容
 */
- (NSDictionary *)dataToSend
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    [retDic setObject:[NSNumber numberWithInt:_messageType] forKey:@"tzType"];
    NSMutableDictionary *contentDic = [[NSMutableDictionary alloc] init];
    [contentDic safeSetObject:_messageId forKey:@"id"];
    [contentDic safeSetObject:_messageImage forKey:@"image"];
    [contentDic safeSetObject:_messageName forKey:@"name"];
    switch (_messageType) {
        case TZChatTypeSpot:
            [contentDic safeSetObject:_messageDesc forKey:@"desc"];
            [contentDic safeSetObject:_messageTimeCost forKey:@"timeCost"];
            break;
            
        case TZChatTypeStrategy:
            [contentDic safeSetObject:_messageDesc forKey:@"desc"];
            [contentDic safeSetObject:_messageTimeCost forKey:@"timeCost"];

            break;
            
        case TZChatTypeFood:
            [contentDic safeSetObject:[NSString stringWithFormat:@"%.1f", _messageRating] forKey:@"rating"];
            [contentDic safeSetObject:_messagePrice forKey:@"price"];
            [contentDic safeSetObject:_messageAddress forKey:@"address"];
            break;
            
        case TZChatTypeHotel:
            [contentDic safeSetObject:[NSString stringWithFormat:@"%.1f", _messageRating] forKey:@"rating"];
            [contentDic safeSetObject:_messagePrice forKey:@"price"];
            [contentDic safeSetObject:_messageAddress forKey:@"address"];
            break;
            
        case TZChatTypeShopping:
            [contentDic safeSetObject:[NSString stringWithFormat:@"%.1f", _messageRating] forKey:@"rating"];
            [contentDic safeSetObject:_messageAddress forKey:@"address"];
            break;
            
        case TZChatTypeCity:
            [contentDic safeSetObject:_messageDesc forKey:@"desc"];
            break;
            
        case TZChatTypeTravelNote:
            [contentDic safeSetObject:_messageDesc forKey:@"desc"];
            [contentDic safeSetObject:_messageDetailUrl forKey:@"detailUrl"];

            break;
            
        default:
            break;
    }
    [retDic setObject:contentDic forKey:@"content"];
    
    return retDic;
}





@end
