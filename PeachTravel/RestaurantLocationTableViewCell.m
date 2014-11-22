//
//  RestaurantLocationTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantLocationTableViewCell.h"

@implementation RestaurantLocationTableViewCell

- (void)awakeFromNib {
   }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setAddress:(NSString *)address
{
    _address = address;
    NSLog(@"%@", _addressBtn.titleLabel.text);
    [_addressBtn setTitle:address forState:UIControlStateNormal];
    CGSize size = [_address sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15]}];
    NSInteger lineCount = (size.width / (self.frame.size.width-60)) + 1;
    _addressBtn.titleLabel.numberOfLines = lineCount;

}
@end
