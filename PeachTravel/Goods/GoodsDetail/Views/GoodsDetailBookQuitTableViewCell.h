//
//  GoodsDetailBookQuitTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/21/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailModel.h"

@interface GoodsDetailBookQuitTableViewCell : UITableViewCell

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;

@property (weak, nonatomic) IBOutlet UILabel *bookContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *quitContentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookContentHightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quitContentHightConstraint;

+ (CGFloat)heightWithGoodsDetail:(GoodsDetailModel *)goodsDetail;

@end
