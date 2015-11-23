//
//  OrderDetailContactTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderContactInfoModel.h"

@interface OrderDetailContactTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelHeightConstraint;
@property (nonatomic, strong) OrderContactInfoModel *contact;

+ (CGFloat)heightOfCellWithContactInfo:(OrderContactInfoModel *)contactInfo;

@end
