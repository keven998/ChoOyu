//
//  HotDestinationCollectionViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/20/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface HotDestinationCollectionViewController : UIViewController

@property (nonatomic, weak) HomeViewController *rootCtl;

/**
 *  当前 viewcontroller 是否正在显示
 */
@property (nonatomic) BOOL isShowing;

@end
