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
    _dialCodeButton.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _dialCodeButton.layer.borderWidth = 0.5;
    
    _lastNameTextField.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _lastNameTextField.layer.borderWidth = 0.5;
    _firstNameTextField.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _firstNameTextField.layer.borderWidth = 0.5;
    _telTextField.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _telTextField.layer.borderWidth = 0.5;

    _messageTextView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _messageTextView.layer.borderWidth = 0.5;

    _firstNameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, _firstNameTextField.frame.size.height)];
    _firstNameTextField.leftViewMode = UITextFieldViewModeAlways;
    
    _telTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, _telTextField.frame.size.height)];
    _telTextField.leftViewMode = UITextFieldViewModeAlways;
    
    _lastNameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, _lastNameTextField.frame.size.height)];
    _lastNameTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}
@end
