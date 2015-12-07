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
    return 120;
}

- (void)awakeFromNib {
    _sendGoodsLinkButton.layer.borderColor = COLOR_LINE.CGColor;
    _sendGoodsLinkButton.layer.borderWidth = 0.5;
    _sendGoodsLinkButton.layer.cornerRadius = 5;
}

- (void)setMessageModel:(MessageModel *)messageModel
{
    _messageModel = messageModel;
    GoodsLinkMessage *message = (GoodsLinkMessage *)_messageModel.baseMessage;
    _goodsTitleLabel.text = message.goodsName;
    _goodsPriceLabel.text = [NSString stringWithFormat:@"价格 :￥%d起", (int)message.price];
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:message.imageUrl] placeholderImage:nil];
}

@end
