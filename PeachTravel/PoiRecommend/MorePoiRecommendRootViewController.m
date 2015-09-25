//
//  MorePoiRecommendRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/25/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MorePoiRecommendRootViewController.h"
#import "MoreDomesticPoiRecommendViewController.h"
#import "MoreForeignPoiRecommendViewController.h"

@interface MorePoiRecommendRootViewController ()

@end

@implementation MorePoiRecommendRootViewController

- (void)viewDidLoad {
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_hilighted.png"] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    self.automaticallyAdjustsScrollViewInsets = NO;
    MoreDomesticPoiRecommendViewController *domesticCtl = [[MoreDomesticPoiRecommendViewController alloc] init];
    MoreForeignPoiRecommendViewController *foreignCtl = [[MoreForeignPoiRecommendViewController alloc] init];
    self.viewControllers = @[domesticCtl, foreignCtl];
    self.animationOptions = UIViewAnimationOptionTransitionNone;
    self.duration = 0;
    self.segmentedTitles = @[@"国内", @"国外"];
    self.selectedColor = APP_THEME_COLOR;
    self.segmentedTitleFont = [UIFont systemFontOfSize:18.0];
    self.normalColor= [UIColor grayColor];
    _destinations = [[Destinations alloc] init];
    domesticCtl.destinations = _destinations;
    foreignCtl.destinations = _destinations;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)goBack
{
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
