//
//  MakePlanSearchCell.h
//  PeachTravel
//
//  Created by 王聪 on 15/8/13.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityDestinationPoi.h"
@interface MakePlanSearchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *addPlan;

@property (nonatomic, strong) CityDestinationPoi * cityPoi;

+ (id)makePlanSearchWithTableView:(UITableView *)tableView;

@end
