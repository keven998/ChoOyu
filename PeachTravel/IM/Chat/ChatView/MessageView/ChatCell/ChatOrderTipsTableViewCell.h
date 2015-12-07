//
//  ChatOrderTipsTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/7/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface ChatOrderTipsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *showOrderDetailBtn;

@property (nonatomic, strong) MessageModel *messageModel;

+ (CGFloat)heightOfCellWithMessageModel:(MessageModel *)messageModel;

@end
