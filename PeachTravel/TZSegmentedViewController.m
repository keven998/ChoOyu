//
//  TZSegmentedViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "TZSegmentedViewController.h"

@interface TZSegmentedViewController ()

@property (nonatomic, strong) UIViewController *currentViewController;

@end

@implementation TZSegmentedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60*_segmentedImages.count, 44)];
    self.navigationItem.titleView = view;
    for (int i=0; i<_segmentedImages.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(60*i, 0, 60, 44)];
        btn.tag = i;
        [btn setImage:[UIImage imageNamed:[_segmentedImages objectAtIndex:i]] forState:UIControlStateNormal];
        [view addSubview:btn];
        [btn addTarget:self action:@selector(changePageAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    for (UIViewController *ctl in _viewControllers) {
        [ctl.view setFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    }
    UIViewController *firstCtl = [_viewControllers firstObject];
    _currentViewController = firstCtl;
    [self addChildViewController:firstCtl];
    [self.view addSubview:firstCtl.view];
}

- (void)setSelectedIndext:(NSUInteger)selectedIndext
{
    _selectedIndext = selectedIndext;
    [self changePage:_selectedIndext];
    
}

- (void)changePageAction:(UIButton *)sender
{
    [self changePage:sender.tag];
}

- (void)changePage:(NSUInteger)pageIndex
{
    _selectedIndext = pageIndex;
    UIViewController *newController = [_viewControllers objectAtIndex:pageIndex];
    
    if ([newController isEqual:_currentViewController]) {
        return;
    }
    [self replaceController:_currentViewController newController:newController];

}
- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            self.currentViewController = newController;
            

        }else{
            self.currentViewController = oldController;
        }
    }];
}


@end
