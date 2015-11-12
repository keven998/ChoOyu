//
//  MakeOrderContactInfoTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MakeOrderContactInfoTableViewCell.h"

@implementation MakeOrderContactInfoTableViewCell

- (void)awakeFromNib {
    _nickNameTextfield.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _nickNameTextfield.layer.borderWidth = 0.5;
    _telTextField.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _telTextField.layer.borderWidth = 0.5;
    _mailTextField.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _mailTextField.layer.borderWidth = 0.5;
    _addressTextField.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _addressTextField.layer.borderWidth = 0.5;
    _messageTextView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _messageTextView.layer.borderWidth = 0.5;

    _nickNameTextfield.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, _nickNameTextfield.frame.size.height)];
    _nickNameTextfield.leftViewMode = UITextFieldViewModeAlways;
    
    _telTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, _nickNameTextfield.frame.size.height)];
    _telTextField.leftViewMode = UITextFieldViewModeAlways;
    
    _mailTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, _nickNameTextfield.frame.size.height)];
    _mailTextField.leftViewMode = UITextFieldViewModeAlways;
    
    _addressTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, _nickNameTextfield.frame.size.height)];
    _addressTextField.leftViewMode = UITextFieldViewModeAlways;
 }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}
@end
