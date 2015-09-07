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
#import "REFrostedViewController.h"

@interface MineViewContoller () <UIScrollViewDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate>
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
    
    self.navigationController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeContentFrame:) name:@"ChangePlanListFrame" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)preSetNavForSlide
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}


#pragma mark - UIGestureRecognizerDelegate 在根视图时不响应interactivePopGestureRecognizer手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.navigationController.viewControllers.count == 1)
        return NO;
    else
        return YES;
}

#pragma mark - navigationDelegate 实现此代理方法也是为防止滑动返回时界面卡死
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //开启滑动手势
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //如果进入我的界面需要隐藏 navi bar
    if ([viewController isKindOfClass:[MineProfileViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    //如果进入我的profile需要隐藏 navi bar
    } else if ([viewController isKindOfClass:[MineViewContoller class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //如果进入REFrostedViewController类型的界面需要隐藏 navi bar
    } else if ([viewController isKindOfClass:[REFrostedViewController class]]){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //其他类型显示 navi bar
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

#pragma mark - 设置导航栏

- (void)setupNavBar
{
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth - 56, 33, 36, 19)];
    [editButton setTitle:@"设置" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [editButton addTarget:self action:@selector(showSettingCtl:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];

    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake((kWindowWidth-108)*0.5, 33, 108, 19)];
    titleLab.text = @"我的·旅行派";
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont boldSystemFontOfSize:18.0];
    titleLab.textColor = [UIColor whiteColor];
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
    MineProfileViewController *profile = [[MineProfileViewController alloc] init];
    [self preSetNavForSlide];
    [self.navigationController pushViewController:profile animated:YES];
}

@end
