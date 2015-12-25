//
//  OrderDetailTravelerPreviewTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/24/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailTravelerPreviewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSArray *travelerList;

+ (CGFloat)heightOfCellWithTravelerList:(NSArray *)travelerList;

@end
