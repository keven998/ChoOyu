//
//  ChatGoodsLinkTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/3/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "ChatGoodsLinkTableViewCell.h"

@implementation ChatGoodsLinkTableViewCell

+ (CGFloat)heightOfCellWithMessageModel:(MessageModel *)messageModel
{
    return 115;
}

- (void)awakeFromNib {
    _bgView.layer.borderColor = COLOR_LINE.CGColor;
    _bgView.layer.borderWidth = 0.5;
    _goodsImageView.clipsToBounds = YES;
    _goodsPriceLabel.adjustsFontSizeToFitWidth = YES;
    self.backgroundColor = APP_PAGE_COLOR;
    _sendGoodsLinkButton.layer.borderColor = COLOR_LINE.CGColor;
    _sendGoodsLinkButton.layer.borderWidth = 0.5;
    _sendGoodsLinkButton.layer.cornerRadius = 8;
    [_sendGoodsLinkButton setBackgroundImage:[ConvertMethods createImageWithColor:APP_PAGE_COLOR] forState:UIControlStateNormal];
}

- (void)setMessageModel:(MessageModel *)messageModel
{
    _messageModel = messageModel;
    GoodsLinkMessage *message = (GoodsLinkMessage *)_messageModel.baseMessage;
    _goodsTitleLabel.text = message.goodsName;
    
    _goodsPriceLabel.text = [NSString stringWithFormat:@"价格 :￥%@起", [self formatCurrentPriceWithPrice:message.price]];
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:message.imageUrl] placeholderImage:nil];
}

- (NSString *)formatCurrentPriceWithPrice:(float)price
{
    NSString *priceStr;
    float currentPrice = round(price*100)/100;
    if (!(currentPrice - (int)currentPrice)) {
        priceStr = [NSString stringWithFormat:@"%d", (int)currentPrice];
    } else {
        NSString *tempPrice = [NSString stringWithFormat:@"%.1f", currentPrice];
        if (!(price - tempPrice.floatValue)) {
            priceStr = [NSString stringWithFormat:@"%.1f", currentPrice];
        } else {
            priceStr = [NSString stringWithFormat:@"%.2f", currentPrice];
        }
        
    }
    return priceStr;
}

@end
