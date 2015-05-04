//
//  ScreeningViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/4/28.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ScreeningViewController.h"
#import "ForeignScreeningViewController.h"
#import "DomesticScreeningViewController.h"
@interface ScreeningViewController ()

@end

@implementation ScreeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(doScreening)];
    

}

-(void)doScreening
{
    
}
- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
