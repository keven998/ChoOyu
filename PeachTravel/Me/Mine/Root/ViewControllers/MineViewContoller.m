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

const CGFloat TopViewH = 300;
@interface MineViewContoller () <UIScrollViewDelegate>
{
    CGFloat contentOffsetY;
    CGFloat oldContentOffsetY;
    CGFloat newContentOffsetY;
}

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *topView;

@end

@implementation MineViewContoller

#pragma mark - lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupMainView];
    [self setupNavBar];
}

#pragma mark - 设置导航栏
- (void)setupNavBar
{
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [editButton setTitle:@"设置" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [editButton addTarget:self action:@selector(showSettingCtl:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
}



// 设置scrollView
- (void)setupMainView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, kWindowWidth, TopViewH*2-100);
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor grayColor];
    scrollView.contentSize = CGSizeMake(0, 1000);
//    scrollView.contentInset = UIEdgeInsetsMake(TopViewH, 0, 0, 0);
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    //
    UIImageView *topView = [[UIImageView alloc] init];
    topView.frame = CGRectMake(0, 0, kWindowWidth, TopViewH);
    topView.image = [UIImage imageNamed:@"testpicture"];
    topView.contentMode = UIViewContentModeScaleAspectFill;
    self.topView = topView;
    [scrollView addSubview:topView];
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
- (void)topViewScrollToTop
{
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.contentOffset = CGPointMake(0, TopViewH);
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self topViewScrollToTop];
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
@end
