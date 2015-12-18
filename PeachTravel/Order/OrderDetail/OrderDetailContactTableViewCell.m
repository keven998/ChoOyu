//
//  OrderDetailContactTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailContactTableViewCell.h"

@implementation OrderDetailContactTableViewCell

+ (CGFloat)heightOfCellWithContactInfo:(OrderTravelerInfoModel *)contactInfo andLeaveMessage:(NSString *)message
{
    if (!message || [message isBlankString]) {
        return 44*2 + 50;
    } else {
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString: message attributes:attribs];
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-95, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return 44*2+50+rect.size.height+30;
    }
}

- (void)awakeFromNib {
    self.clipsToBounds = YES;
}

- (void)setContact:(OrderTravelerInfoModel *)contact
{
    _contact = contact;
    _nameLabel.text = [NSString stringWithFormat:@"%@ %@", _contact.lastName, _contact.firstName];
    _telLabel.text = _contact.telDesc;
}

- (void)setLeaveMessage:(NSString *)leaveMessage
{
    _leaveMessage = leaveMessage;
    _messageLabel.text = _leaveMessage;
    if (_leaveMessage && ![_leaveMessage isBlankString]) {
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:_leaveMessage attributes:attribs];
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-95, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        _messageLabelHeightConstraint.constant = 10+rect.size.height;
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
