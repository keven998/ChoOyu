//
//  ChatOrderTipsTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/7/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "ChatOrderTipsTableViewCell.h"
#import "PeachTravel-swift.h"

@implementation ChatOrderTipsTableViewCell

+ (CGFloat)heightOfCellWithMessageModel:(MessageModel *)messageModel
{
    return 200;
}

- (void)awakeFromNib {
    _bgView.layer.borderColor = COLOR_LINE.CGColor;
    _bgView.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setMessageModel:(MessageModel *)messageModel
{
    OrderTipsMessage *message = (OrderTipsMessage *)messageModel.baseMessage;
    _orderContentLabel.text = message.content;
    _orderStatusLabel.text = message.title;
    _orderNameLabel.text = [NSString stringWithFormat:@"商品名称:  %@", message.goodsName];
    _orderIdLabel.text = [NSString stringWithFormat:@"订单编号:  %ld", message.orderId];
}

@end
