//
//  DestinationsView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DestinationsView : UIView

@property (nonatomic, strong) NSArray *destinations;

- (instancetype)initWithFrame:(CGRect)frame andContentOffsetX:(CGFloat)offsetX;

@end
