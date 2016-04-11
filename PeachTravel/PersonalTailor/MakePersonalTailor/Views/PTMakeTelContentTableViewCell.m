//
//  PTMakeTelContentTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/5/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTMakeTelContentTableViewCell.h"

@implementation PTMakeTelContentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dailCode = @"86";
    self.dailCodeButton.layer.borderColor = COLOR_LINE.CGColor;
    self.dailCodeButton.layer.borderWidth = 0.5;
    _telConentTextfield.delegate = self;
    
    NSString *content = [NSString stringWithFormat:@"*电话"];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
    [attr addAttribute:NSForegroundColorAttributeName value:COLOR_PRICE_RED range:NSMakeRange(0, 1)];
    _typeLabel.attributedText = attr;

}

- (void)setDailCode:(NSString *)dailCode
{
    [_dailCodeButton setTitle:[NSString stringWithFormat:@"+%@", dailCode] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [_telConentTextfield resignFirstResponder];
        return NO;
    }
    return YES;
}


@end
