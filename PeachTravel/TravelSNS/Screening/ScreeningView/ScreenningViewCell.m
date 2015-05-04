//
//  ScreenningViewCell.m
//  PeachTravel
//
//  Created by dapiao on 15/4/28.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ScreenningViewCell.h"

@implementation ScreenningViewCell

- (void)awakeFromNib {
    // Initialization code
    self.layer.cornerRadius = 5;
    self.layer.borderColor = APP_THEME_COLOR.CGColor;
    self.layer.borderWidth = 1;
}

@end
