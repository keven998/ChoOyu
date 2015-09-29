//
//  CityDetailHeaderView.h
//  CityDetailHeaderView
//
//  Created by 冯宁 on 15/9/21.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityPoi.h"
#import "CityHeaderView.h"
@class CityDetailHeaderView;

@protocol CityDetailHeaderViewDelegate <NSObject>
@required
- (void)restaurantBtnAction;
- (void)spotBtnAction;
- (void)guideBtnAction;
- (void)shoppingBtnAction;
- (void)planBtnAction;
- (void)journeyBtnAction;
- (void)imageListAction;
- (void)travelMonthAction;
- (void)descriptionAction;

- (void)headerFrameDidChange:(CityDetailHeaderView*)headerView;

@end

@interface CityDetailHeaderView : CityHeaderView

//@property (nonatomic, strong) CityPoi *cityPoi;
@property (nonatomic, weak) id <CityDetailHeaderViewDelegate> delegate;

- (CGFloat)headerHeight;

@end
