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
    self.footprintCount.textColor = APP_THEME_COLOR;
    self.planCount.textColor = APP_THEME_COLOR;
}

@end
