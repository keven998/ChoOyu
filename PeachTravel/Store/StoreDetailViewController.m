//
//  StoreDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/29/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "StoreDetailViewController.h"
#import "RCTRootView.h"
#import "RCTBridgeModule.h"


@interface StoreDetailViewController ()

@end

@implementation StoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"旅行派之家";
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSURL *jsCodeLocation = [NSURL URLWithString:@"http://192.168.1.79:8081/src/index.ios.bundle?platform=ios&dev=true"];
    
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                        moduleName:@"StoreDetailClass"
                                                 initialProperties:nil
                                                     launchOptions:nil];
    rootView.frame = CGRectMake(0, 0, kWindowWidth, kWindowHeight);
    
    [self.view addSubview:rootView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
