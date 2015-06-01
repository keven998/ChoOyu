//
//  DistributionViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/16.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "DistributionViewController.h"

@interface DistributionViewController ()

@end

@implementation DistributionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
