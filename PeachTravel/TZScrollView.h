//
//  TZScrollView.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZScrollView : UIView

@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) CGFloat itemHeight;
@property (nonatomic, strong) UIColor *itemBackgroundColor;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *viewsOnScrollView;

@end
