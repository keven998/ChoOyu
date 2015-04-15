//
//  TZViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/5/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZViewController.h"

@interface TZViewController ()

@end

@implementation TZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController.navigationBarHidden) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 63.0)];
        bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UINavigationItem *navTitle = [[UINavigationItem alloc] init];
        navTitle.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
        [bar pushNavigationItem:navTitle animated:YES];
        bar.shadowImage = [ConvertMethods createImageWithColor:APP_THEME_COLOR];
        _customNavigationItem = navTitle;
        [self.view addSubview:bar];
    } else {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 48, 30)];
        //[button setTitle:@"返回" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:17.0];
        button.titleEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 0);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = barButton;
        _customNavigationItem = self.navigationItem;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isShowing = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isShowing = NO;
}

- (void)goBack
{
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
