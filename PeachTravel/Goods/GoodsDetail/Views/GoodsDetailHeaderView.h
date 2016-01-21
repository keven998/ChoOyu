//
//  GoodsDetailHeaderView.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailModel.h"

@interface GoodsDetailHeaderView : UIView

+ (CGFloat)heightWithGoodsmodel:(GoodsDetailModel *)goodsModel;

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;

@end
