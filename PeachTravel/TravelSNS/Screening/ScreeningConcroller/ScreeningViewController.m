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
    
    UIBarButtonItem *rbi = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(doScreening)];
    NSMutableDictionary *textAttrs=[NSMutableDictionary dictionary];
    NSMutableDictionary *dTextAttrs = [NSMutableDictionary dictionaryWithDictionary:textAttrs];
    dTextAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    [rbi setTitleTextAttributes:dTextAttrs forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = rbi;


}
- (void)hideDestinationBar
{
    CGRect frame = self.selectPanel.superview.frame;
    frame.origin.y = CGRectGetHeight(self.view.bounds);
    [UIView animateWithDuration:0.3 animations:^{
        self.selectPanel.superview.frame = frame;
    } completion:^(BOOL finished) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }];
}

- (void)showDestinationBar
{
    CGRect frame = self.selectPanel.superview.frame;
    frame.origin.y = CGRectGetHeight(self.view.bounds) - 49;
    [UIView animateWithDuration:0.3 animations:^{
        self.selectPanel.superview.frame = frame;
    } completion:^(BOOL finished) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}
-(void)doScreening
{
    
}
- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
