//
//  GoodsDetailBookTipsTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailModel.h"

@interface GoodsDetailBookTipsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *feeDescLabel;

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;

+ (CGFloat)heightWithGoodsDetail:(GoodsDetailModel *)goodsDetail;

@end
