//
//  SearchDestinationTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SearchDestinationTableViewCell.h"

@implementation SearchDestinationTableViewCell

- (void)awakeFromNib {
    _statusBtn.layer.cornerRadius = 2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
