//
//  PXAlertView+Customization.h
//  PXAlertViewDemo
//
//  Created by Michal Zygar on 21.10.2013.
//  Copyright (c) 2013 panaxiom. All rights reserved.
//

#import "PXAlertView.h"

@interface PXAlertView (Customization)

- (void)setWindowTintColor:(UIColor *)color;
- (void)setBackgroundColor:(UIColor *)color;

- (void)setTitleColor:(UIColor *)color;
- (void)setTitleFont:(UIFont *)font;
- (void)setCancelFount:(UIFont *)font;

- (void)setMessageColor:(UIColor *)color;
- (void)setMessageFont:(UIFont *)font;

- (void)setCancelButtonBackgroundColor:(UIColor *)color;
- (void)setOtherButtonBackgroundColor:(UIColor *)color;
- (void)setAllButtonsBackgroundColor:(UIColor *)color;

- (void)setCancelButtonNonSelectedBackgroundColor:(UIColor *)color;
- (void)setOtherButtonNonSelectedBackgroundColor:(UIColor *)color;
- (void)setAllButtonsNonSelectedBackgroundColor:(UIColor *)color;

- (void)setCancelButtonTextColor:(UIColor *)color;
- (void)setAllButtonsTextColor:(UIColor *)color;
- (void)setOtherButtonTextColor:(UIColor *)color;

- (void)useDefaultIOS7Style;

- (void)useCustomStyle;

#pragma mark - 增加自定义方法
- (void)setCancelButtonTextColor:(UIColor *)color andHighLightedColor:(UIColor *)highLightedColor;

- (void)setOtherButtonTextColor:(UIColor *)color andHighLightedColor:(UIColor *)highLightedColor;

- (void)setAllButtonsTextColor:(UIColor *)color andHighLightedColor:(UIColor *)highLightedColor;

- (void)setCancelUnderlineWithColor:(UIColor *)color;

@end