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
    
    UITextView * textDesc = [[UITextView alloc] init];
    textDesc.frame = CGRectMake(0, 0, kWindowWidth, 200);
    textDesc.text = self.desc;
    textDesc.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:textDesc];
    
}


@end
