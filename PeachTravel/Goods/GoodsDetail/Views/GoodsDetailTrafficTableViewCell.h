//
//  GoodsDetailTrafficTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/21/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailModel.h"

@interface GoodsDetailTrafficTableViewCell : UITableViewCell

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

+ (CGFloat)heightWithGoodsDetail:(GoodsDetailModel *)goodsDetail;

@end
