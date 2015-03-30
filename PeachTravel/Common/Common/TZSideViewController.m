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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
