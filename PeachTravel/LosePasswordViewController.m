//
//  LosePasswordViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "LosePasswordViewController.h"

@interface LosePasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;

@end

@implementation LosePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    tapBackground.numberOfTapsRequired = 1;
    tapBackground.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapBackground];

}

- (void)tapBackground:(id)sender
{
    if ([_phoneLabel isFirstResponder]) {
        [_phoneLabel resignFirstResponder];
    }
}


@end
