//
//  MakeOrderPackageTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MakeOrderPackageTableViewCell.h"

@implementation MakeOrderPackageTableViewCell

+ (CGFloat)heightWithPackageTitle:(NSString *)title
{
    CGFloat retHeight = 0;
    
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
    NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString: title attributes:attribs];
    CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-110, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    if (rect.size.height > 21) {
        retHeight = rect.size.height + 10;
    } else {
        retHeight = 21;
    }
    retHeight += 25;
    return retHeight;
}

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [_orderContentBtn setBackgroundImage:[[UIImage imageNamed:@"icon_makeOrder_packageNormal"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 15)] forState:UIControlStateNormal];
    [_orderContentBtn setBackgroundImage:[[UIImage imageNamed:@"icon_makeOrder_packageSelected"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 25, 25)] forState:UIControlStateSelected];
    _priceLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setPackageTitle:(NSString *)packageTitle
{
    _packageTitle = packageTitle;
    _contentLabel.text = _packageTitle;
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
    NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString: _packageTitle attributes:attribs];
    CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-110, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    if (rect.size.height > 21) {
        _contentLabelHeightConstraint.constant = rect.size.height + 10;
    } else {
        _contentLabelHeightConstraint.constant = 21;
    }
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    _orderContentBtn.selected = _isSelected;
}

@end
