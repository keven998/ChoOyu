//
//  BNGoodsDetailPackageTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/14/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNGoodsDetailModel.h"

@interface BNGoodsDetailPackageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (nonatomic, strong) BNGoodsDetailModel *goodsDetail;

+ (CGFloat)heightWithGoodsDetail:(GoodsDetailModel *)goodsDetail;

@end
