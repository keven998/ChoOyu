//
//  UserCouponTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "UserCouponTableViewCell.h"

@implementation UserCouponTableViewCell

- (void)awakeFromNib {
    [_selectButton setImage:[UIImage imageNamed:@"icon_coupons_normal"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"icon_coupons_selected"] forState:UIControlStateSelected];
    _headerTitleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
}

- (void)setUserCouponDetail:(UserCouponDetail *)userCouponDetail
{
    _userCouponDetail = userCouponDetail;
    _titleLabel.text = _userCouponDetail.title;
    if (_userCouponDetail.desc) {
        _descLabel.text = _userCouponDetail.desc;
    } else {
        _descLabel.text = @"全场通用";
    }
    if (_userCouponDetail.limitMoney == 0) {
        _headerTitleLabel.text = @"现金券";
        _headerImageView.image = [[UIImage imageNamed:@"icon_coupons_yellow"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    } else {
        _headerTitleLabel.text = @"代金券";
        _headerImageView.image = [[UIImage imageNamed:@"icon_coupons_red"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    }
    _limitMoneyLabel.text = _userCouponDetail.limitMoneyDesc;
    _useDateLabel.text = [NSString stringWithFormat:@"有效期至: %@", _userCouponDetail.useDate];
    
    NSMutableAttributedString *discountString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@", _userCouponDetail.formatDiscount]];
    [discountString addAttributes:@{
                                    NSFontAttributeName:[UIFont boldSystemFontOfSize:22],
                                    } range:NSMakeRange(0, 1)];
    [discountString addAttributes:@{
                                    NSFontAttributeName:[UIFont boldSystemFontOfSize:35],
                                    } range:NSMakeRange(1, discountString.length-1)];
    _discountLabel.attributedText = discountString;
}

@end
