//
//  BusinessHomeViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BusinessHomeViewController.h"
#import "BNGoodsListRootViewController.h"
#import "BNOrderListRootViewController.h"

@interface BusinessHomeViewController ()

@end

@implementation BusinessHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的店铺";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)myOrdersAction:(id)sender {
    BNOrderListRootViewController *ctl = [[BNOrderListRootViewController alloc] init];
    ctl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)myGoodsAction:(id)sender {
    BNGoodsListRootViewController *ctl = [[BNGoodsListRootViewController alloc] init];
    ctl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctl animated:YES];
}


@end
