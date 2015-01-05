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
    [SVProgressHUD dismiss];
    
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.frame = CGRectMake(0.0, 0.0, 40.0, 27.0);
//    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    [backButton setImage:[UIImage imageNamed:@"ic_navigation_back"] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
//    self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    leftBtn.image = [UIImage imageNamed:@"ic_navigation_back"];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)goBack
{
    [SVProgressHUD dismiss];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
