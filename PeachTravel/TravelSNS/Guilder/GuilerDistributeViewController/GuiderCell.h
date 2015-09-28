//
//  GuiderCell.h
//  PeachTravel
//
//  Created by dapiao on 15/7/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GuiderDistribute;
@interface GuiderCell : UITableViewCell

+ (id)guiderWithTableView:(UITableView *)tableView;

@property (nonatomic, strong)GuiderDistribute * guiderDistribute;

@end
