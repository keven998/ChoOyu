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
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToAllPets)];
    [backBtn setImage:[UIImage imageNamed:@"ic_navigation_back"]];
    self.navigationItem.leftBarButtonItem = backBtn;
    
}

- (void)goBackToAllPets
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
