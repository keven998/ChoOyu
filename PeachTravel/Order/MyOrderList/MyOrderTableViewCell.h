//
//  MyOrderTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailModel.h"

@interface MyOrderTableViewCell : UITableViewCell

@property (nonatomic, strong) OrderDetailModel *orderDetail;

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *packageNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactBusiness;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payOrderBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *payOrderBtn;
@end
