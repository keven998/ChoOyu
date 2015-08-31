//
//  GuiderProfileTourViewCell.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileTourViewCell.h"

@implementation GuiderProfileTourViewCell

+ (id)guiderProfileTourWithTableView:(UITableView *)tableView
{
    static NSString * ID = @"guideCell";
    
    UINib * nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    
    [tableView registerNib:nib forCellReuseIdentifier:ID];
    
    return [tableView dequeueReusableCellWithIdentifier:ID];

}

- (void)awakeFromNib {
    // Initialization code
    
    self.tourTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    self.tourTitle.textColor = UIColorFromRGB(0x646464);
    
    [self.footprintBtn.titleLabel setTextColor:UIColorFromRGB(0x969696)];
    [self.footprintBtn.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:12.0]];
    
    [self.planBtn.titleLabel setTextColor:UIColorFromRGB(0x969696)];
    [self.planBtn.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:12.0]];
    
    [self.tourBtn.titleLabel setTextColor:UIColorFromRGB(0x969696)];
    [self.tourBtn.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:12.0]];
    
    self.footprintCount.textColor = APP_THEME_COLOR;
    self.planCount.textColor = APP_THEME_COLOR;
    self.tourCount.textColor = APP_THEME_COLOR;
}

@end
