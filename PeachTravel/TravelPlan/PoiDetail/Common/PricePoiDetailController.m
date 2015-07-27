//
//  PricePoiDetailController.m
//  PeachTravel
//
//  Created by 王聪 on 15/7/27.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "PricePoiDetailController.h"

@interface PricePoiDetailController ()

@end

@implementation PricePoiDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel * label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    label.text = self.desc;
    label.textAlignment = UITextAlignmentCenter;
    
    [self.view addSubview:label];
}


@end
