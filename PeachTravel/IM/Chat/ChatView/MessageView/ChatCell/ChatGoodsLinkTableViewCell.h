//
//  ChatGoodsLinkTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/3/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface ChatGoodsLinkTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *goodsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UIButton *sendGoodsLinkButton;

@property (nonatomic, strong) MessageModel *messageModel;

+ (CGFloat)heightOfCellWithMessageModel:(MessageModel *)messageModel;

@end
