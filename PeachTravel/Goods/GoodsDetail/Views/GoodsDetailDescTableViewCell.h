//
//  GoodsDetailDescTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailModel.h"

@interface GoodsDetailDescTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timecostLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) GoodsDetailModel *goodsDetail;

+ (CGFloat)heightWithGoodsDetail:(GoodsDetailModel *)goodsDetail;

@end
