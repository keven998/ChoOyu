//
//  MineViewContoller.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/1.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "MineViewContoller.h"
#import "MineProfileViewController.h"
#import "SettingHomeViewController.h"
#import "MineHeaderView.h"
#import "MineContentRootViewController.h"
@interface MineViewContoller () <UIScrollViewDelegate>
{
    CGFloat contentOffsetY;
    CGFloat oldContentOffsetY;
    CGFloat newContentOffsetY;
    
    CGFloat TopViewH;
}

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *topView;
@property (nonatomic, weak) UIViewController *contentViewCtl;

@end

@implementation MineViewContoller

#pragma mark - lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TopViewH = kWindowWidth*255/414;

    [self setupMainView];
    [self setupNavBar];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_background.png"] forBarMetrics:UIBarMetricsCompact];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeContentFrame:) name:@"ChangePlanListFrame" object:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

#pragma mark - 设置导航栏

- (void)setupNavBar
{
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [editButton setTitle:@"设置" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [editButton addTarget:self action:@selector(showSettingCtl:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];

}

// 设置scrollView
- (void)setupMainView
{
    MineHeaderView *topView = [[MineHeaderView alloc] init];
    topView.frame = CGRectMake(0, 0, kWindowWidth, TopViewH);
    topView.image = [UIImage imageNamed:@"testpicture"];
    topView.contentMode = UIViewContentModeScaleAspectFill;
    self.topView = topView;
    [self.view addSubview:topView];
    
    MineContentRootViewController *contentViewCtl = [[MineContentRootViewController alloc] init];
    contentViewCtl.view.backgroundColor = [UIColor redColor];
    self.contentViewCtl = contentViewCtl;
    [self addChildViewController:contentViewCtl];
    [self.view addSubview:contentViewCtl.view];
    contentViewCtl.view.frame = CGRectMake(0, TopViewH, kWindowWidth, kWindowHeight-TopViewH-49);
    [contentViewCtl willMoveToParentViewController:self];
}

#pragma mark - UIScrollViewDelegate
/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"contentY:%f",scrollView.contentOffset.y);
    // 向下拽了多少距离
    CGFloat down = -(TopViewH * 0.5) - scrollView.contentOffset.y;
    NSLog(@"down%f",down);
    if (down > 200) return;
    
    CGRect frame = self.topView.frame;
    // 5决定图片变大的速度,值越大,速度越快
    frame.size.height = TopViewH + down*0.6;
    self.topView.frame = frame;
}
 */

#pragma mark - 实现头部View的滚动
// 向上滚动
- (void)topViewScrollToTop
{
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.frame = CGRectMake(0, -TopViewH+64, kWindowWidth, TopViewH-64);
        
        _contentViewCtl.view.frame = CGRectMake(0, 64, kWindowWidth, kWindowHeight - 64 - 49);
    }];
}

// 向下滚动
- (void)topViewScrollToBottom
{
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.frame = CGRectMake(0, 0, kWindowWidth, TopViewH);
        
        _contentViewCtl.view.frame = CGRectMake(0, TopViewH, kWindowWidth, kWindowHeight-TopViewH-49);

    }];
}

// 向下拉的时候改变frame
- (void)topViewBeginScaleWithScrollH:(CGFloat)scrollH
{
    if (scrollH > 200) {
        return;
    }
    CGRect frame = self.topView.frame;
    // 5决定图片变大的速度,值越大,速度越快
    frame.size.height = scrollH;
    self.topView.frame = frame;
}

#pragma mark - action
/**
 *  进入设置界面
 *
 *  @param sender
 */
- (void)showSettingCtl:(id)sender
{
    SettingHomeViewController *profileCtr = [[SettingHomeViewController alloc] init];
    profileCtr.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:profileCtr animated:YES];
}

- (void)changeContentFrame:(NSNotification *)note
{
    NSString *scrollH = note.userInfo[@"scrollH"];
    CGFloat scrollHeight = [scrollH floatValue];
    
    NSLog(@"scrollHeight:%f",scrollHeight);
    
    if (scrollHeight > 0) {
        [self topViewScrollToTop];
    } else if (scrollHeight < 0){
        [self topViewScrollToBottom];
        
    }
}

@end
