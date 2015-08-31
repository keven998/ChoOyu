//
//  GuiderProfileTourViewCell.h
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuiderProfileTourViewCell : UITableViewCell

+ (id)guiderProfileTourWithTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UILabel *footprintCount;

@property (weak, nonatomic) IBOutlet UILabel *planCount;

@property (weak, nonatomic) IBOutlet UIButton *footprintBtn;

@property (weak, nonatomic) IBOutlet UIButton *planBtn;

@property (weak, nonatomic) IBOutlet UIButton *tourBtn;


@end
