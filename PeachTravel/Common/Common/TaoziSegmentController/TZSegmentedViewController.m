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
    
    // 设置segment的样式并添加到控制器中
    UIImageView * bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 48)];
    // 设置图片填充格式
    bgView.contentMode = UIViewContentModeScaleAspectFill;
    bgView.clipsToBounds = YES;
    bgView.userInteractionEnabled = YES;
    bgView.image = [UIImage imageNamed:@"Artboard_Top_Bg"];
    [self.view addSubview:bgView];
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:_segmentedTitles];
    segControl.tintColor = [UIColor colorWithRed:148 / 256.0 green:201 / 256.0 blue:98 / 256.0 alpha:1.0];
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat segControlX = (screenW - 136) / 2;
    segControl.frame = CGRectMake(segControlX, 10, 136, 28);
    segControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    segControl.selectedSegmentIndex = 0;
    [bgView addSubview:segControl];
    self.view.backgroundColor = [UIColor whiteColor];
    [segControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    _segmentControl = segControl;
    

    
    for (UIViewController *ctl in _viewControllers) {
//        [ctl.view setFrame:self.view.bounds];
        [ctl.view setFrame:CGRectMake(0, 48, self.view.bounds.size.width, self.view.bounds.size.height - 70)];
    }
    UIViewController *firstCtl = [_viewControllers firstObject];
    _currentViewController = firstCtl;
    [self addChildViewController:firstCtl];
    [self.view addSubview:firstCtl.view];
}

// 设置导航栏标题
- (void)setNavBarTitle:(NSString *)navBarTitle
{
    _navBarTitle = navBarTitle;
    
    self.navigationItem.title = navBarTitle;
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
