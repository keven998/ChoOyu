//
//  DomesticDestinationCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/9.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "DomesticDestinationCell.h"

@implementation DomesticDestinationCell

- (void)awakeFromNib {
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 13.0;
    self.layer.borderColor = APP_THEME_COLOR.CGColor;
}

@end
