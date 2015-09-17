//
//  MakePlanSearchCell.m
//  PeachTravel
//
//  Created by 王聪 on 15/8/13.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "MakePlanSearchCell.h"

@implementation MakePlanSearchCell

+ (id)makePlanSearchWithTableView:(UITableView *)tableView
{
    static NSString * ID = @"makePlanSearchCell";
    
    UINib * nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    
    [tableView registerNib:nib forCellReuseIdentifier:ID];
    
    return [tableView dequeueReusableCellWithIdentifier:ID];
}

- (void)awakeFromNib {
    // Initialization code
}

@end
