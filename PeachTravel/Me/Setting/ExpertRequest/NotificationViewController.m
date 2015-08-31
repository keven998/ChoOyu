//
//  NotificationViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _alertBgkView.layer.cornerRadius = 4.0;
    _alertBgkView.clipsToBounds = YES;
    _actionBtn.layer.cornerRadius = 2.0;
    _actionBtn.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.55];
    [_actionBtn addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    NSLog(@"NotificationCtl dealloc");
}

- (void)dismiss:(id)sender
{
    [self dismissNotiView];
}

- (void)showNotiViewInController:(UIViewController *)containerController
{
    [containerController addChildViewController:self];
    [containerController.view addSubview:self.view];
    [self willMoveToParentViewController:containerController];
    [self startShowAnimation];
}

- (void)dismissNotiView
{
    [self.view removeFromSuperview];
    [self willMoveToParentViewController:nil];
    [self removeFromParentViewController];
}

#pragma mark - private methods

- (void)startShowAnimation
{
    self.view.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)endShowAnimation
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissNotiView];
}

@end
