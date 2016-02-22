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
    _headerImageView.image = [[UIImage imageNamed:@"icon_coupons_red"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [_selectButton setImage:[UIImage imageNamed:@"icon_coupons_normal"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"icon_coupons_selected"] forState:UIControlStateSelected];
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
    _limitMoneyLabel.text = _userCouponDetail.limitMoneyDesc;
    _useDateLabel.text = [NSString stringWithFormat:@"有效期至: %@", _userCouponDetail.useDate];
    
    NSMutableAttributedString *discountString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%d", (int)_userCouponDetail.discount]];
    [discountString addAttributes:@{
                                    NSFontAttributeName:[UIFont boldSystemFontOfSize:22],
                                    } range:NSMakeRange(0, 1)];
    [discountString addAttributes:@{
                                    NSFontAttributeName:[UIFont boldSystemFontOfSize:35],
                                    } range:NSMakeRange(1, discountString.length-1)];
    _discountLabel.attributedText = discountString;
}

@end
