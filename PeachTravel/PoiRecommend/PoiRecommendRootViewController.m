//
//  PoiRecommendRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "PoiRecommendRootViewController.h"
#import "DomesticPoiRecommendViewController.h"
#import "ForeignPoiRecommendViewController.h"

@interface PoiRecommendRootViewController ()

@end

@implementation PoiRecommendRootViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    ForeignPoiRecommendViewController *foreignCtl = [[ForeignPoiRecommendViewController alloc] init];
    DomesticPoiRecommendViewController *domestic = [[DomesticPoiRecommendViewController alloc] init];
    self.viewControllers = @[domestic, foreignCtl];
    self.segmentedTitles = @[@"国内", @"国外"];
    self.selectedColor = APP_THEME_COLOR;
    self.segmentedTitleFont = [UIFont systemFontOfSize:18.0];
    self.normalColor= [UIColor grayColor];
    
    [super viewDidLoad];
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
