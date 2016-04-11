//
//  PTMakeOtherContentTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/6/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTMakeOtherContentTableViewCell.h"

@implementation PTMakeOtherContentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _contentTextView.layer.borderWidth = 0.5;
    _contentTextView.layer.borderColor = COLOR_LINE.CGColor;
    _contentTextView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
