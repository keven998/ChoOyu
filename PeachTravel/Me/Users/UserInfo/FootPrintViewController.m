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

@property (nonatomic, strong) FootprintMapViewController *footprintMapCtl;

@end

@implementation FootPrintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    
    
    _footprintMapCtl = [[FootprintMapViewController alloc] init];
    [_footprintMapCtl.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    [self addChildViewController:_footprintMapCtl];
    [self.view addSubview:_footprintMapCtl.view];
    [_footprintMapCtl didMoveToParentViewController:self];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 15, 44, 44)];
    [backBtn setImage:[UIImage imageNamed:@"ic_navigation_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 50, 50)];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"添加" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addFootprint:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)addFootprint:(id)sender
{
    float lat = random()%90;
    float lng = random()%90;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    [_footprintMapCtl addPoint:location];
    
}
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}
@end
