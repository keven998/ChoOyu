//
//  TZProgressHUD.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/5/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZProgressHUD : UIViewController

/**
 *  开始显示
 *
 *  @param viewController 
 */
- (void)showHUDInViewController:(UIViewController *)viewController;

- (void)showHUD;

/**
 *  隐藏
 */
- (void)hideTZHUD;


@end
