//
//  DestinationsView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DestinationsViewDelegate <NSObject>

- (void)destinationDidSelect:(NSInteger)selectedIndex;

- (void)willAddDestination;


@end

@interface DestinationsView : UIView

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) NSArray *destinations;

/**
 *  是否可以添加目的地，如果可以的话那么是从三账单的目的地列表进来的
 */
@property (nonatomic) BOOL isCanAddDestination;

@property (nonatomic, assign) id <DestinationsViewDelegate> delegate;

@end
