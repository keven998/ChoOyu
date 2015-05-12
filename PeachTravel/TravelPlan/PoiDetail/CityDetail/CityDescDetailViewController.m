//
//  CityDescDetailViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/5/11.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "CityDescDetailViewController.h"

@interface CityDescDetailViewController ()

@end

@implementation CityDescDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情简介";
    
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel * desLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 500)];
    desLabel.numberOfLines = 0 ;
    desLabel.text = self.des;
    [self.view addSubview:desLabel];
    
}


@end
