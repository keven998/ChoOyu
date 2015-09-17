//
//  DomesticCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/9.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "DomesticCell.h"

@implementation DomesticCell

- (void)awakeFromNib {
    _tiltleLabel.textColor = [UIColor whiteColor];
    _tiltleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
}

@end
