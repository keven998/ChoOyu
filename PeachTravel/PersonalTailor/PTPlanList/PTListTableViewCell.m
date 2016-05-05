//
//  PTListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTListTableViewCell.h"
#import "CityDestinationPoi.h"

@implementation PTListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _statusLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setPtDetailModel:(PTDetailModel *)ptDetailModel
{
    _ptDetailModel = ptDetailModel;
    NSMutableString *destinationStr = [[NSMutableString alloc] init];
    for (CityDestinationPoi *poi in _ptDetailModel.destinations) {
        if ([poi isEqual:[_ptDetailModel.destinations lastObject]]) {
            [destinationStr appendString:poi.zhName];
        } else {
            [destinationStr appendFormat:@"%@, ", poi.zhName];
        }
    }
    _contentLabel.text = [NSString stringWithFormat:@"[%@] %ld日游 %@", destinationStr, _ptDetailModel.timeCost, ptDetailModel.service];
    _subtitleLabel.text = [NSString stringWithFormat:@"在 %@ 号发布了需求", _ptDetailModel.createTimeStr];
    _grabNumberLabel.text = [NSString stringWithFormat:@"已有%ld位商家抢单", _ptDetailModel.takersCnt];
    if (_ptDetailModel.earnestMoney > 0) {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"定金%ld元 总预算%ld元", (NSInteger)_ptDetailModel.earnestMoney, (NSInteger)_ptDetailModel.budget]];
        [content addAttribute:NSForegroundColorAttributeName value:COLOR_PRICE_RED range:NSMakeRange(2, [[[NSString alloc] initWithFormat:@"%ld", (NSInteger)_ptDetailModel.earnestMoney] length])];
        [content addAttribute:NSForegroundColorAttributeName value:COLOR_PRICE_RED range:NSMakeRange(2+[[[NSString alloc] initWithFormat:@"%ld", (NSInteger)_ptDetailModel.earnestMoney] length]+5, [[[NSString alloc] initWithFormat:@"%ld", (NSInteger)_ptDetailModel.budget] length])];
        _priceLabel.attributedText = content;
        
    } else {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"总预算%ld元", (NSInteger)_ptDetailModel.budget]];
        [content addAttribute:NSForegroundColorAttributeName value:COLOR_PRICE_RED range:NSMakeRange(3, [[[NSString alloc] initWithFormat:@"%ld", (NSInteger)_ptDetailModel.budget] length])];
        _priceLabel.attributedText = content;
    }
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_ptDetailModel.consumer.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _nickNameLabel.text = _ptDetailModel.consumer.nickName;
    
}

@end
