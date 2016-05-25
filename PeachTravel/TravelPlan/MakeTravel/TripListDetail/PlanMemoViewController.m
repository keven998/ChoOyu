//
//  PlanMemoViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 5/19/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PlanMemoViewController.h"

@interface PlanMemoViewController ()

@end

@implementation PlanMemoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    _textView.layer.cornerRadius = 4.0;
    _textView.clipsToBounds = YES;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.text = _memo;
    
    self.navigationItem.title = @"添加旅行备注";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveEdit)];
    self.navigationItem.rightBarButtonItem = saveItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveEdit
{
    _memo = _textView.text;
    [_delegate memoSave:_memo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
