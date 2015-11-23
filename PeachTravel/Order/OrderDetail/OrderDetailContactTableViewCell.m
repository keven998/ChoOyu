//
//  OrderDetailContactTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailContactTableViewCell.h"

@implementation OrderDetailContactTableViewCell

+ (CGFloat)heightOfCellWithContactInfo:(OrderContactInfoModel *)contactInfo
{
    if (!contactInfo.message || [contactInfo.message isBlankString]) {
        return 44*2 + 50;
    } else {
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:contactInfo.message attributes:attribs];
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-95, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return 44*2+50+rect.size.height+30;
    }
}

- (void)awakeFromNib {
    self.clipsToBounds = YES;
}

- (void)setContact:(OrderContactInfoModel *)contact
{
    _contact = contact;
    _nameLabel.text = [NSString stringWithFormat:@"%@ %@", _contact.lastName, _contact.firstName];
    _telLabel.text = _contact.tel;
    _messageLabel.text = _contact.message;
    if (_contact.message && ![_contact.message isBlankString]) {
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:_contact.message attributes:attribs];
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-95, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        _messageLabelHeightConstraint.constant = 10+rect.size.height;
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
