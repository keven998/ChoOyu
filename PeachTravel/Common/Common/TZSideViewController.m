//
//  TZSideViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "TZSideViewController.h"

@interface TZSideViewController ()

@property (nonatomic)CGRect detailViewFrame;

@end

@implementation TZSideViewController

- (id)initWithDetailViewFrame:(CGRect)rect
{
    if (self = [super init]) {
        _detailViewFrame = rect;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSideDetailView)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideSideDetailView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showSideDetailView
{
    [[[[UIApplication sharedApplication] delegate] window].rootViewController addChildViewController:self];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.view];
    
    [self addChildViewController:self.detailViewController];
    [self.view addSubview:self.detailViewController.view];
    [self.detailViewController didMoveToParentViewController:self];
    self.detailViewController.view.frame = CGRectMake(self.view.frame.size.width+_detailViewFrame.size.width, _detailViewFrame.origin.y, _detailViewFrame.size.width, _detailViewFrame.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        self.detailViewController.view.frame = _detailViewFrame;
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];

    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideSideDetailView
{
    [self.view removeFromSuperview];
}

@end
