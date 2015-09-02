//
//  MineViewContoller.h
//  PeachTravel
//
//  Created by 王聪 on 15/9/1.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol topViewBeginScroll <NSObject>

- (void)topViewBeginScroll:(CGFloat)scrollH;

@end

@interface MineViewContoller : UIViewController

// 向下滚动
- (void)topViewScrollToBottom;

// 向下滚动
- (void)topViewScrollToTop;

@property (nonatomic, assign)id<topViewBeginScroll> delegate;

@end
