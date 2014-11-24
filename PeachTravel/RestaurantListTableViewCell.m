//
//  RestaurantListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantListTableViewCell.h"

@implementation RestaurantListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setIsEditing:(BOOL)isEditing
{
    if (isEditing) {
        _mapViewBtn.hidden = YES;
        _titleLabelConstraint.constant = 0;
        _addressLabelConstraint.constant = 0;
        
    } else
    {
        _mapViewBtn.hidden = NO;
        _titleLabelConstraint.constant = 60;
        _addressLabelConstraint.constant = 60;

    }

}
@end
