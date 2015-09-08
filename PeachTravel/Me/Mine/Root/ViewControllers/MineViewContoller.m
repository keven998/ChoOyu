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
#import "MakePlanViewController.h"
#import "ForeignViewController.h"
#import "DomesticViewController.h"

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

@property (nonatomic, weak) UIButton *addPlan;

@end

@implementation MineViewContoller

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![AccountManager shareAccountManager].isLogin) {
        [self userLogin];
    }
    
    TopViewH = kWindowWidth*200/414;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeContentFrame:) name:@"ChangePlanListFrame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAddPlanBtnFrame:) name:@"ChangeAddPlanFrame" object:nil];
    
    [[AccountManager shareAccountManager].account loadUserInfoFromServer:^(bool isSuccess) {
        if (isSuccess) {
            [self updateContent];
        }
    }];
    
}

- (void)userLogin
{
    if ([AccountManager shareAccountManager].isLogin) {
        return;
    }
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
}

- (void)setupAddPlanBtn
{
    UIButton *addPlan = [UIButton buttonWithType:UIButtonTypeCustom];
    addPlan.frame = CGRectMake((kWindowWidth-50)*0.5, self.view.frame.size.height-110, 50, 50);
    [addPlan addTarget:self action:@selector(addPlan:) forControlEvents:UIControlEventTouchUpInside];
    [addPlan setImage:[UIImage imageNamed:@"plan_add"] forState:UIControlStateNormal];
    addPlan.highlighted = NO;
    self.addPlan = addPlan;
    [self.view addSubview:addPlan];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setupMainView];
    [self setupNavBar];
    [self setupAddPlanBtn];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![[self.navigationController.viewControllers lastObject]isKindOfClass:[BaseProfileViewController class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)preSetNavForSlide
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)updateContent
{
    _topView.account = [AccountManager shareAccountManager].account;
}

#pragma mark - UIGestureRecognizerDelegate 在根视图时不响应interactivePopGestureRecognizer手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.navigationController.viewControllers.count == 1)
        return NO;
    else
        return YES;
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
    topView.image = [UIImage imageNamed:@"bg_master"];
    topView.contentMode = UIViewContentModeScaleToFill;
    self.topView = topView;
    [self.view addSubview:topView];
    topView.account = [AccountManager shareAccountManager].account;
    
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
    
    if (scrollHeight > 0) {
        [self topViewScrollToTop];
    } else if (scrollHeight < 0){
        [self topViewScrollToBottom];
        
    }
}

- (void)changeAddPlanBtnFrame:(NSNotification *)note
{
    NSString *scrollW = note.userInfo[@"scrollW"];
    CGFloat scrollWidth = [scrollW floatValue];
    
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, _addPlan.center.y);
    center.x -= scrollWidth;
    _addPlan.center = center;
}

// 点击头部进入个人Profile
- (void)tapHeaderView:(UITapGestureRecognizer *)tap
{
    MineProfileViewController *profile = [[MineProfileViewController alloc] init];
    [self preSetNavForSlide];
    [self.navigationController pushViewController:profile animated:YES];
}

// 添加计划
- (void)addPlan:(UIButton *)btn
{
    [self makePlan];
}

- (void)makePlan
{
    [MobClick event:@"navigation_item_plan_create"];
    
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    domestic.destinations = destinations;
    foreignCtl.destinations = destinations;
    makePlanCtl.destinations = destinations;
    makePlanCtl.viewControllers = @[domestic, foreignCtl];
    domestic.makePlanCtl = makePlanCtl;
    foreignCtl.makePlanCtl = makePlanCtl;
    makePlanCtl.animationOptions = UIViewAnimationOptionTransitionNone;
    makePlanCtl.duration = 0;
    makePlanCtl.segmentedTitles = @[@"国内", @"国外"];
    makePlanCtl.navBarTitle = @"选择目的地";
    
    makePlanCtl.selectedColor = APP_THEME_COLOR;
    makePlanCtl.segmentedTitleFont = [UIFont systemFontOfSize:18.0];
    makePlanCtl.normalColor= [UIColor grayColor];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:makePlanCtl];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
