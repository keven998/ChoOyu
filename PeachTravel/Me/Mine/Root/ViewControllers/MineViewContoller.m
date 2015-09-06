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
@property (nonatomic, weak) MineHeaderView *topView;
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
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth - 56, 33, 36, 19)];
    [editButton setTitle:@"设置" forState:UIControlStateNormal];
    [editButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [editButton addTarget:self action:@selector(showSettingCtl:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];

    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake((kWindowWidth-108)*0.5, 33, 108, 19)];
    titleLab.text = @"我的·旅行派";
    titleLab.font = [UIFont boldSystemFontOfSize:18.0];
    titleLab.textColor = UIColorFromRGB(0xFFFFFF);
    [self.view addSubview:titleLab];
}

// 设置scrollView
- (void)setupMainView
{
    MineHeaderView *topView = [[MineHeaderView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, TopViewH)];
    topView.image = [UIImage imageNamed:@"testpicture"];
    topView.contentMode = UIViewContentModeScaleAspectFill;
    self.topView = topView;
    [self.view addSubview:topView];
    
    // 添加手势
    UITapGestureRecognizer *tapHeaderView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderView:)];
    [topView addGestureRecognizer:tapHeaderView];
    
    MineContentRootViewController *contentViewCtl = [[MineContentRootViewController alloc] init];
    contentViewCtl.view.backgroundColor = APP_PAGE_COLOR;
    self.contentViewCtl = contentViewCtl;
    [self addChildViewController:contentViewCtl];
    [self.view addSubview:contentViewCtl.view];
    contentViewCtl.view.frame = CGRectMake(0, TopViewH, kWindowWidth, kWindowHeight-TopViewH-49);
    [contentViewCtl willMoveToParentViewController:self];
}

#pragma mark - 实现头部View的滚动
// 向上滚动
- (void)topViewScrollToTop
{
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.frame = CGRectMake(0, -TopViewH+64, kWindowWidth, TopViewH-64);
        _topView.contentView.alpha = 0;
        _contentViewCtl.view.frame = CGRectMake(0, 64, kWindowWidth, kWindowHeight - 64 - 49);
    }];
}

// 向下滚动
- (void)topViewScrollToBottom
{
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.frame = CGRectMake(0, 0, kWindowWidth, TopViewH);
        _topView.contentView.alpha = 1;
        _contentViewCtl.view.frame = CGRectMake(0, TopViewH, kWindowWidth, kWindowHeight-TopViewH-49);

    }];
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

// 点击头部进入个人Profile
- (void)tapHeaderView:(UITapGestureRecognizer *)tap
{
    NSLog(@"---------");
    MineProfileViewController *profile = [[MineProfileViewController alloc] init];
    [self.navigationController pushViewController:profile animated:YES];
}

@end
