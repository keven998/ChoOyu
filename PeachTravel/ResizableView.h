//
//  ResizableView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResizableView : UIButton

@property (nonatomic, copy) NSString *content;
@property (nonatomic) CGFloat resizeHeight;
@property (nonatomic, strong) UIColor *contentColor;
@property (nonatomic, strong) UIFont *contentFont;
@property (nonatomic) NSUInteger numberOfLine;

- (void)showMoreContent;

- (void)hideContent;

/**
 *  全部展开需要的行数
 *
 *  @return
 */
- (NSInteger)maxNumberOfLine;

@end
