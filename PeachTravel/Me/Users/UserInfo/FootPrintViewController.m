//
//  FootPrintViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "FootPrintViewController.h"
#import "FootprintMapViewController.h"

@interface FootPrintViewController ()

@end

@implementation FootPrintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    FootprintMapViewController *footprintMapCtl = [[FootprintMapViewController alloc] init];
    [footprintMapCtl.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    [self addChildViewController:footprintMapCtl];
    [self.view addSubview:footprintMapCtl.view];
    [footprintMapCtl didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
