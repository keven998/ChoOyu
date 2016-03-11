//
//  BNOrderListTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/8/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNOrderDetailModel.h"

@protocol BNOrderListTableViewCellDelegate <NSObject>

@optional
//和某人聊天
- (void)chatWithUser:(NSInteger)userId;

@end

@interface BNOrderListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong)BNOrderDetailModel *orderDetail;

@property (nonatomic, weak) id<BNOrderListTableViewCellDelegate> delegate;

@end
