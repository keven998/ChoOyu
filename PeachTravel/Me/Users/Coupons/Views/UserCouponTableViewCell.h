//
//  UserCouponTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 2/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCouponDetail.h"

@interface UserCouponTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *limitMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *useDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (nonatomic, strong) UserCouponDetail *userCouponDetail;



@end
