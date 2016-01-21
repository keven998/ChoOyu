//
//  GoodsDetailStoreInfoTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/21/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreDetailModel.h"

@interface GoodsDetailStoreInfoTableViewCell : UITableViewCell

@property (nonatomic, strong) StoreDetailModel *storeDetail;

@property (nonatomic, strong) UILabel *storeNameLabel;

+ (CGFloat)storeHeaderHeightWithStoreDetail:(StoreDetailModel *)storeDetail;

@end
