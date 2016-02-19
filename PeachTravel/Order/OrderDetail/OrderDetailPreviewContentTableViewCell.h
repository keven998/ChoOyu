//
//  OrderDetailPreviewContentTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailModel.h"

@interface OrderDetailPreviewContentTableViewCell : UITableViewCell

@property (nonatomic, strong) OrderDetailModel *orderDetail;

@property (weak, nonatomic) IBOutlet UIButton *goodsNameBtn;
@property (weak, nonatomic) IBOutlet UILabel *packageNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodsNameHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *packageNameHeightConstarint;

+ (CGFloat)heightOfCellWithOrderDetail:(OrderDetailModel *)orderDetail;

@end
