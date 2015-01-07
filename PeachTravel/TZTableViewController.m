//
//  :TZTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZTableViewController.h"

@interface TZTableViewController ()

@end

@implementation TZTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    leftBtn.image = [UIImage imageNamed:@"ic_navigation_back"];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
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
      

    [self.navigationController popViewControllerAnimated:YES];
}

@end
