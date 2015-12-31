//
//  OrderDetailStatusListTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/31/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailStatusListTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *statusList;

+ (CGFloat)heightOfCellWithStatusList:(NSArray *)statusList;

@end
