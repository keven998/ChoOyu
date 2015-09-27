//
//  TZEmojiToolBar.h
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARGUMENTS.h"

@protocol TZEmojiToolBarDelegate <NSObject>

- (void)changePageWithIndex:(NSInteger)index;
- (void)sendBtnClickEvent;

@end

@interface TZEmojiToolBar : UIView

@property (nonatomic, strong) UIPageControl* pageControl;

@property (nonatomic, weak) id <TZEmojiToolBarDelegate> delegate;

- (instancetype)initWithModelArray:(NSArray*)array height:(CGFloat)height;

@end
