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
#import "PoiRecommendSearchViewController.h"

@interface MorePoiRecommendRootViewController ()

@end

@implementation MorePoiRecommendRootViewController

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal.png"] forState:UIControlStateNormal];
    
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
    foreignCtl.view.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [searchButton setImage:[UIImage imageNamed:@"ic_common_search.png"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchDestination:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
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

- (void)searchDestination:(id)sender
{
    PoiRecommendSearchViewController *ctl = [[PoiRecommendSearchViewController alloc] init];
    ctl.destinations = self.destinations;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
}

@end
