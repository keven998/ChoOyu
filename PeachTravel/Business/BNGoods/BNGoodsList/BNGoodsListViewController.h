//
//  BNGoodsListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BNGoodsDetailModel.h"

@interface BNGoodsListViewController : UIViewController

@property (nonatomic) NSInteger storeId;
@property (nonatomic) BNGoodsStatus goodsStatus;

@property (nonatomic, weak) UIViewController *containerCtl;

@end
