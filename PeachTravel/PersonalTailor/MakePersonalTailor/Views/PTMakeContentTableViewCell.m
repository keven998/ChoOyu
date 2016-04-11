//
//  PTMakeContentTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/5/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTMakeContentTableViewCell.h"

@implementation PTMakeContentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setTypeDesc:(NSString *)typeDesc
{
    _typeDesc = typeDesc;
    NSString *content = [NSString stringWithFormat:@"*%@", _typeDesc];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
    [attr addAttribute:NSForegroundColorAttributeName value:COLOR_PRICE_RED range:NSMakeRange(0, 1)];
    _typeLabel.attributedText = attr;
    _contentTextfield.delegate = self;
}

 - (void)setContentPlaceHolder:(NSString *)contentPlaceHolder
{
    _contentPlaceHolder = contentPlaceHolder;
    _contentTextfield.placeholder = _contentPlaceHolder;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [_contentTextfield resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
