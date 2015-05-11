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
//@property (nonatomic, strong) UIView *indicateView;
@property (nonatomic, strong) UISegmentedControl *segmentControl;

@end

@implementation TZSegmentedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    _selectedIndext = -1;
    int titleCount = 0;
    if (_segmentedNormalImages) {
        titleCount = (int)_segmentedNormalImages.count;
    } else if (_segmentedTitles) {
        titleCount = (int)_segmentedTitles.count;
    }
    
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:_segmentedTitles];
    segControl.tintColor = APP_THEME_COLOR;
    segControl.frame = CGRectMake(0, 0, 136, 28);
    segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    segControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segControl;
    [segControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    _segmentControl = segControl;
    
    for (UIViewController *ctl in _viewControllers) {
        [ctl.view setFrame:self.view.bounds];
    }
    UIViewController *firstCtl = [_viewControllers firstObject];
    _currentViewController = firstCtl;
    [self addChildViewController:firstCtl];
    [self.view addSubview:firstCtl.view];
}

-(void)segmentAction:(UISegmentedControl *)segment {
    [self changePage:segment.selectedSegmentIndex];
}

- (void)setSelectedIndext:(NSInteger)selectedIndext
{
    if (selectedIndext == _selectedIndext) {
        return;
    }
    [self changePage:selectedIndext];
}

- (void)finishSwithPages
{
    
}

- (void)changePageAction:(UIButton *)sender
{
    [self changePage:sender.tag];
}

- (void)changePage:(NSInteger)pageIndex
{
//    if (_selectedIndext >= 0) {
//        UIButton *fbtn = [_segmentedBtns objectAtIndex:_selectedIndext];
//        fbtn.selected = NO;
//    }
//    _selectedIndext = pageIndex;
//    
//    UIButton *btn = [_segmentedBtns objectAtIndex:_selectedIndext];
//    btn.selected = YES;
//    [UIView animateWithDuration:0.2 animations:^{
//        _indicateView.center = CGPointMake(btn.center.x, 42);
//    }];

    UIViewController *newController = [_viewControllers objectAtIndex:pageIndex];
    
    if ([newController isEqual:_currentViewController]) {
        return;
    }
    [self replaceController:_currentViewController newController:newController];
}

- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:_duration options:_animationOptions animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            self.currentViewController = newController;
        }else{
            self.currentViewController = oldController;
        }
    }];
    [self finishSwithPages];
}


@end
