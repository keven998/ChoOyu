//
//  TZViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/5/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZViewController.h"

@interface TZViewController ()

@end

@implementation TZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToAllPets)];
    [backBtn setImage:[UIImage imageNamed:@"ic_navigation_back"]];
    self.navigationItem.leftBarButtonItem = backBtn;

}

- (void)goBackToAllPets
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
