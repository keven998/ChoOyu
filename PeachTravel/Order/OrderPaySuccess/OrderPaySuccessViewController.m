//
//  OrderPaySuccessViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/28/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderPaySuccessViewController.h"
#import "OrderDetailViewController.h"

@interface OrderPaySuccessViewController ()

@end

@implementation OrderPaySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"支付成功";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)checkOrderDetail:(id)sender {
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    if ([[viewControllers objectAtIndex:viewControllers.count-2] isKindOfClass:[OrderDetailViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    OrderDetailViewController *ctl = [[OrderDetailViewController alloc] init];
    ctl.orderId = _orderId;
    [viewControllers replaceObjectAtIndex:viewControllers.count-1 withObject:ctl];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (IBAction)backHomeViewController:(id)sender {
    HomeViewController *homeViewController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).homeViewController;
    if (homeViewController.selectedIndex) {
        homeViewController.selectedIndex = 0;
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
