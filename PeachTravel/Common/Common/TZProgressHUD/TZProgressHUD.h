//
//  TZProgressHUD.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/5/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZProgressHUD : UIView

@property (nonatomic, copy) NSString *status;   //提示的语言


/**
 *  开始显示
 *
 *  @param viewController 
 */
- (void)showHUDInViewController:(UIViewController *)viewController;

/**
 *  开始显示
 *
 *  @param viewController
 */
- (void)showHUDInView:(UIView *)contentView;



/**
 *  开始显示带有提示的菊花
 *
 *  @param viewController
 *  @param status 提示语
 */
- (void)showHUDInViewController:(UIViewController *)viewController withStatus:(NSString *)status;


- (void)showHUD;

/**
 *  隐藏
 */
- (void)hideTZHUD;


@end
