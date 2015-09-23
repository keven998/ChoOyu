//
//  CityDetailHeaderBottomView.h
//  CityDetailHeaderView
//
//  Created by 冯宁 on 15/9/22.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CityDetailHeaderBottomViewDelegate <NSObject>
@required
- (void)restaurantBtnAction;
- (void)spotBtnAction;
- (void)guideBtnAction;
- (void)shoppingBtnAction;
- (void)planBtnAction;
- (void)journeyBtnAction;
@end

@interface CityDetailHeaderBottomView : UIView

@property (nonatomic,weak) id <CityDetailHeaderBottomViewDelegate> delegate;

@end
