//
//  LocationTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "LocationTableViewCell.h"

@implementation LocationTableViewCell

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
    CGSize size = [_address sizeWithAttributes:@{NSFontAttributeName :[UIFont fontWithName:@"MicrosoftYaHei" size:12]}];
    NSInteger lineCount = (size.width / (self.frame.size.width-60)) + 1;
    _addressBtn.titleLabel.numberOfLines = lineCount;
}

- (void)setTel:(NSString *)tel
{
    _tel = tel;
    NSLog(@"%@", _addressBtn.titleLabel.text);
    [_telephoneBtn setTitle:_tel forState:UIControlStateNormal];
}

+ (CGFloat)heightForAddressCellWithAddress:(NSString *)address
{
    CGSize size = [address sizeWithAttributes:@{NSFontAttributeName :[UIFont fontWithName:@"MicrosoftYaHei" size:12.0]}];
    NSInteger lineCount = (size.width / (kWindowWidth-60)) + 1;
    CGFloat addressHeight = lineCount*size.height+10;
    return addressHeight+80;
}

@end
