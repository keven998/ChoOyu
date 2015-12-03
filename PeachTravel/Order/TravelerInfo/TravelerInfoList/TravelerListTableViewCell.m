//
//  TravelerListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "TravelerListTableViewCell.h"

@implementation TravelerListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTravelerInfo:(OrderTravelerInfoModel *)travelerInfo
{
    _travelerInfo = travelerInfo;
    _nameLabel.text = [NSString stringWithFormat:@"%@ %@", _travelerInfo.lastName, _travelerInfo.firstName];
    _telLabel.text = travelerInfo.tel;
    _IDNumberLabel.text = [NSString stringWithFormat:@"%@ %@", _travelerInfo.IDCategoryDesc, _travelerInfo.IDNumber];
}
@end
