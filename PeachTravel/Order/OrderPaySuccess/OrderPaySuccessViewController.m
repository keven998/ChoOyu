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
    }
}

- (IBAction)backHomeViewController:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}
@end
