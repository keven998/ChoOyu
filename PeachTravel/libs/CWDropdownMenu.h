//
//  CWDropdownMenu.h
//  PeachTravel
//
//  Created by 王聪 on 15/8/31.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Extension.h"
@class CWDropdownMenu;

@protocol CWDropdownMenuDelegate <NSObject>
@optional
- (void)dropdownMenuDidDismiss:(CWDropdownMenu *)menu;
- (void)dropdownMenuDidShow:(CWDropdownMenu *)menu;
@end

@interface CWDropdownMenu : UIView
@property (nonatomic, weak) id<CWDropdownMenuDelegate> delegate;

+ (instancetype)menu;

/**
 *  显示
 */
- (void)showFrom:(UIView *)from;
/**
 *  销毁
 */
- (void)dismiss;

/**
 *  内容
 */
@property (nonatomic, strong) UIView *content;
/**
 *  内容控制器
 */
@property (nonatomic, strong) UIViewController *contentController;
@end
