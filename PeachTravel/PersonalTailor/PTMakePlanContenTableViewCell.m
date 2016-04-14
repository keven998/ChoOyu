//
//  PTMakePlanContenTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/12/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTMakePlanContenTableViewCell.h"

@implementation PTMakePlanContenTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _contentTextView.layer.borderWidth = 0.5;
    _contentTextView.layer.borderColor = COLOR_LINE.CGColor;
    _contentTextView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (_endEditBlock) {
        _endEditBlock(textView.text);
    }
}


@end
