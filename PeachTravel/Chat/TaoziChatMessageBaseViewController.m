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
    
    _titleLabel.text = _messageName;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_messageImage] placeholderImage:nil];
    
    switch (_chatType) {
        case TZChatTypeSpot:
            _headerLabel.text = @"  景点";
            [_propertyBtn setTitle:_messageTimeCost forState:UIControlStateNormal];
            _descLabel.text = _messageDesc;
            
            break;
            
        case TZChatTypeCity:
            _headerLabel.text = @"  城市";
            
            break;
            
        case TZChatTypeFood: {
            _headerLabel.text = @"  美食";
            NSString *propertyStr = [NSString stringWithFormat:@"%.1f  %@",_messageRating, _messagePrice];
            _descLabel.text = _messageAddress;
            [_propertyBtn setTitle:propertyStr forState:UIControlStateNormal];

        }
            break;
            
        case TZChatTypeHotel:
            _headerLabel.text = @"  酒店";
            
            break;
            
        case TZChatTypeShopping:
            _headerLabel.text = @"  购物";
            
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
    ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:_chatter isGroup:_isGroup];
    chatCtl.title = _chatTitle;
    [ChatSendHelper sendTaoziMessageWithString:@"" andExtMessage:[self dataToSend] toUsername:_chatter isChatGroup:_isGroup requireEncryption:NO];
    [_delegate sendSuccess:chatCtl];
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
    [retDic setObject:[NSNumber numberWithInt:_chatType] forKey:@"tzType"];
    NSMutableDictionary *contentDic = [[NSMutableDictionary alloc] init];
    [contentDic safeSetObject:_messageId forKey:@"id"];
    [contentDic safeSetObject:_messageImage forKey:@"image"];
    [contentDic safeSetObject:_messageName forKey:@"name"];
    switch (_chatType) {
        case TZChatTypeSpot:
            [contentDic safeSetObject:_messageDesc forKey:@"desc"];
            [contentDic safeSetObject:_messageTimeCost forKey:@"timeCost"];
            break;
            
        case TZChatTypeCity:
            [contentDic safeSetObject:_messageDesc forKey:@"desc"];
            break;
            
        case TZChatTypeFood:
            [contentDic safeSetObject:[NSNumber numberWithFloat:_messageRating] forKey:@"rating"];
            [contentDic safeSetObject:_messagePrice forKey:@"price"];
            [contentDic safeSetObject:_messageAddress forKey:@"address"];
            break;
            
        case TZChatTypeHotel:
            [contentDic safeSetObject:[NSNumber numberWithFloat:_messageRating] forKey:@"rating"];
            [contentDic safeSetObject:_messagePrice forKey:@"price"];
            [contentDic safeSetObject:_messageAddress forKey:@"address"];
            break;
            
        case TZChatTypeShopping:
            [contentDic safeSetObject:[NSNumber numberWithFloat:_messageRating] forKey:@"rating"];
            [contentDic safeSetObject:_messageAddress forKey:@"address"];
            break;
            
        default:
            break;
    }
    [retDic setObject:contentDic forKey:@"content"];
    return retDic;
}





@end
