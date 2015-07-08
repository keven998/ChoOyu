//
//  GuilderTableViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/23.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuilderTableViewController.h"

@interface GuilderTableViewController ()

@end

@implementation GuilderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    label.text = @"我是达人详情,哈哈哈,哈哈哈,哈哈哈,哈哈哈,哈哈哈";
    label.font = [UIFont systemFontOfSize:30];
    label.numberOfLines = 0;
    
    [self.view addSubview:label];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
