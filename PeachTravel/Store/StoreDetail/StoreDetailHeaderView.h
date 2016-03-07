//
//  StoreDetailHeaderView.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/19/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreDetailModel.h"

@interface StoreDetailHeaderView : UIView

@property (nonatomic, strong) StoreDetailModel *storeDetail;


+ (CGFloat)storeHeaderHeightWithStoreDetail:(StoreDetailModel *)storeDetail;

@end
