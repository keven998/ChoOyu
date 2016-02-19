//
//  OrderPriceDetailView.h
//  PeachTravel
//
//  Created by liangpengshuai on 2/19/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OrderDetailModel.h"

@interface OrderPriceDetailView : UIView

@property (nonatomic, strong) OrderDetailModel *orderDetail;

- (void)showPriceDetailView;
- (void)showPriceDetailViewWithAnimated:(BOOL)animated;

- (void)hidePriceDetailView;
- (void)hidePriceDetailViewWithAnimated:(BOOL)animated;

@end
