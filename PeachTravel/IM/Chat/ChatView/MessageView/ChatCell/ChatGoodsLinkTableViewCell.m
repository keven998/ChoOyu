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
    _goodsTitleLabel.text = _messageModel.goodsModel.goodsName;
    _goodsPriceLabel.text = [NSString stringWithFormat:@"价格 :￥%d起", (int)_messageModel.goodsModel.currentPrice];
    
}

@end
