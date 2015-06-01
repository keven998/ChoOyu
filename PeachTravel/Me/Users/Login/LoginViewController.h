//
//  LoginViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/11.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^loginCompletion)(BOOL completed);

@interface LoginViewController : TZViewController

@property (nonatomic) BOOL isPushed;       //判断是 push 还是 present

- (id) initWithCompletion:(loginCompletion)completion;

@end
