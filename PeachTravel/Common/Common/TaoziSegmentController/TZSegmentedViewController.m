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
@property (nonatomic, strong) UIView *indicateView;

@end

@implementation TZSegmentedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _selectedIndext = -1;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60*_segmentedNormalImages.count, 44)];
    self.navigationItem.titleView = view;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<_segmentedNormalImages.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(60*i, 0, 60, 44)];
        btn.tag = i;
        if (_segmentedNormalImages) {
            [btn setImage:[UIImage imageNamed:[_segmentedNormalImages objectAtIndex:i]] forState:UIControlStateNormal];
        }
        if (_segmentedSelectedImages) {
            [btn setImage:[UIImage imageNamed:[_segmentedSelectedImages objectAtIndex:i]] forState:UIControlStateSelected];

        }
        if (_segmentedTitles) {
            [btn setTitle:_segmentedTitles[i] forState:UIControlStateNormal];
            [btn setTitleColor:_normalColor forState:UIControlStateNormal];
            [btn setTitleColor:_selectedColor forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:8];
        }
        [view addSubview:btn];
        [btn addTarget:self action:@selector(changePageAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [array addObject:btn];
    }
    _segmentedBtns = array;
    
    for (UIViewController *ctl in _viewControllers) {
        [ctl.view setFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    }
    UIViewController *firstCtl = [_viewControllers firstObject];
    _currentViewController = firstCtl;
    [self addChildViewController:firstCtl];
    [self.view addSubview:firstCtl.view];
    _indicateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, 4)];
    _indicateView.backgroundColor = _selectedColor;
    UIButton *btn = [_segmentedBtns firstObject];
    _indicateView.center = CGPointMake(btn.center.x, 42);
    self.selectedIndext = 0;
    [view addSubview:_indicateView];
}

- (void)setSelectedIndext:(NSInteger)selectedIndext
{
    if (selectedIndext == _selectedIndext) {
        return;
    }
    _selectedIndext = selectedIndext;
    [self changePage:_selectedIndext];
    
}

- (void)changePageAction:(UIButton *)sender
{
    [self changePage:sender.tag];
}

- (void)changePage:(NSUInteger)pageIndex
{
   
    UIButton *fbtn = [_segmentedBtns objectAtIndex:_selectedIndext];
    fbtn.selected = NO;
    _selectedIndext = pageIndex;
    
    UIButton *btn = [_segmentedBtns objectAtIndex:_selectedIndext];
    btn.selected = YES;
    [UIView animateWithDuration:0.2 animations:^{
        _indicateView.center = CGPointMake(btn.center.x, 42);
    }];

    UIViewController *newController = [_viewControllers objectAtIndex:pageIndex];
    
    if ([newController isEqual:_currentViewController]) {
        return;
    }
    [self replaceController:_currentViewController newController:newController];

}
- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
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
