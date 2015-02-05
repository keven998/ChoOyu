//
//  DestinationsView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DestinationsViewDelegate <NSObject>

- (void)distinationDidSelect:(NSInteger)selectedIndex;

@end

@interface DestinationsView : UIView

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) NSArray *destinations;

@property (nonatomic, assign) id <DestinationsViewDelegate> delegate;

@end
