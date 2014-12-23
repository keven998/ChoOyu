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
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius = 2.0;
    self.layer.shadowColor = APP_DIVIDER_COLOR.CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0, 0.5);
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = 0.5;
}

@end
