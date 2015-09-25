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
#import "MorePoiRecommendRootViewController.h"

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
    
    UIButton *moreBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn setImage:[UIImage imageNamed:@"icon_navi_gray_more.png"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreAction:)forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setFrame:CGRectMake(0, 0, 30, 30)];
    moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)moreAction:(id)sender
{
    MorePoiRecommendRootViewController *ctl = [[MorePoiRecommendRootViewController alloc] init];
    [self.navigationController pushViewController:ctl animated:YES];
}


@end
