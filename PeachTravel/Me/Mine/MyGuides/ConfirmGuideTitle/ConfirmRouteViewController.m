//
//  ConfirmRouteViewController.m
//  lvxingpai
//
//  Created by liangpengshuai on 14-8-25.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import "ConfirmRouteViewController.h"

@interface ConfirmRouteViewController ()

@end

@implementation ConfirmRouteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.cornerRadius = 3.0;
    _routeTitle.layer.cornerRadius = 3.0;
    [_routeTitle becomeFirstResponder];
    _routeTitle.layer.borderColor = UIColorFromRGB(0x999999).CGColor;
    _routeTitle.layer.borderWidth = 0.5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
