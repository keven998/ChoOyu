//
//  GoodsDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/26/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import "RCTRootView.h"
#import "RCTBridgeModule.h"
#import "StoreDetailViewController.h"

@interface GoodsDetailViewController ()<RCTBridgeModule>

@end

@implementation GoodsDetailViewController

RCT_EXPORT_MODULE();


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    NSURL *jsCodeLocation = [NSURL URLWithString:@"http://192.168.1.79:8081/src/index.ios.bundle?platform=ios&dev=true"];

    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                        moduleName:@"GoodsDetailClass"
                                                 initialProperties:nil
                                                     launchOptions:nil];
    rootView.frame = CGRectMake(0, 0, kWindowWidth, kWindowHeight);
    [self.view addSubview:rootView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDetail) name:@"gotoStoreDetailNoti" object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)storeDetail
{
    dispatch_async(dispatch_get_main_queue(), ^{
        StoreDetailViewController *ctl = [[StoreDetailViewController alloc] init];
        [self.navigationController pushViewController:ctl animated:YES];
    });

}

RCT_EXPORT_METHOD(makePhone:(NSString *)tel){
    NSString *number = tel;// 此处读入电话号码
    NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];//打电话

}

RCT_EXPORT_METHOD(gotoStoreDetail:(NSString *)storeId){
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoStoreDetailNoti" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

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
