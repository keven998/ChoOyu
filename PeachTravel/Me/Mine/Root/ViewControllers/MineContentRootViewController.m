//
//  MineContentRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/1/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "MineContentRootViewController.h"
#import "ContactListViewController.h"
#import "PlansListTableViewController.h"

@interface MineContentRootViewController () <UIScrollViewDelegate>

//保存 切换按钮
@property (nonatomic, strong) NSArray *segmentBtns;

//保存 切换按钮标题
@property (nonatomic, strong) NSArray *segmentTitles;

//保存 切换按钮常态图片
@property (nonatomic, strong) NSArray *segmentNormalImages;

//保存 切换按钮选中态图片
@property (nonatomic, strong) NSArray *segmentSelectedImages;

//保存 包含的 controller
@property (nonatomic, strong) NSArray *contentControllers;

@property (nonatomic, strong)  UIScrollView *contentView;

@property (nonatomic, strong) UIView *indicatorView;

@end

@implementation MineContentRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _segmentTitles = @[@"旅行计划", @"联系人"];
    
    NSMutableArray *arrays = [[NSMutableArray alloc] init];
    
    ContactListViewController *contactList = [[ContactListViewController alloc] init];
    PlansListTableViewController *plansCtl = [[PlansListTableViewController alloc] init];
    [arrays addObject:plansCtl];
    [arrays addObject:contactList];

    _contentControllers = arrays;

    [self setupSegmentView];
    [self setupContentView];
    [self changePage:0];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - setter & getter


#pragma mark - private methods

/**
 *  初始化切换按钮
 */
- (void)setupSegmentView
{
    UIView *segmentPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 49)];
    segmentPanel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:segmentPanel];
    
    NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
    
    float btnWidth = self.view.bounds.size.width/[_segmentTitles count];
    float btnHeight = 49;
    float offsetX = 0;
    
    _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnWidth, 2)];
    _indicatorView.backgroundColor = APP_THEME_COLOR;
    [segmentPanel addSubview:_indicatorView];
    
    for (int i = 0; i < [_segmentTitles count]; i++) {
        NSString *title = [_segmentTitles objectAtIndex:i];
        NSString *imageNormalName = [_segmentNormalImages objectAtIndex:i];
        NSString *imageSelectName = [_segmentSelectedImages objectAtIndex:i];
        UIButton *segmentBtn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 0, btnWidth, btnHeight)];
        [segmentBtn setTitle:title forState:UIControlStateNormal];
        [segmentBtn setImage:[UIImage imageNamed:imageNormalName] forState:UIControlStateNormal];
        [segmentBtn setImage:[UIImage imageNamed:imageSelectName] forState:UIControlStateSelected];
        [segmentBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        [segmentBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateSelected];
        [segmentBtn addTarget:self action:@selector(changePageAction:) forControlEvents:UIControlEventTouchUpInside];
        [segmentPanel addSubview:segmentBtn];
        [buttonArray addObject:segmentBtn];
        offsetX += btnWidth;
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 8, 0.5, 33)];
        spaceView.backgroundColor = COLOR_LINE;
        [segmentPanel addSubview:spaceView];
    }
    _segmentBtns = buttonArray;
}

/**
 *  设置具体内容
 */
- (void)setupContentView
{
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 49, self.view.bounds.size.width, self.view.bounds.size.height-49)];
    _contentView.pagingEnabled = YES;
    _contentView.delegate = self;
    _contentView.contentSize = CGSizeMake(self.view.bounds.size.width*_contentControllers.count, _contentView.bounds.size.height);
    [self.view addSubview:_contentView];
    
    CGFloat offsetX = 0;
    
    for (int i = 0; i < _contentControllers.count; i++) {
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = _contentView.bounds.size.height;
        UIViewController *ctl = [_contentControllers objectAtIndex:i];
        [self addChildViewController:ctl];
        ctl.view.frame = CGRectMake(offsetX, 0, width, height);
        
        [_contentView addSubview:ctl.view];
        [ctl willMoveToParentViewController:self];
        offsetX += width;
        
        if (i == 0) {
            PlansListTableViewController *plansCtl = (PlansListTableViewController *)ctl;
            plansCtl.tableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0);
        } else {
            ContactListViewController *contactCtl = (ContactListViewController *)ctl;
            contactCtl.contactTableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0);
        }
    }
}

- (void)changePage:(NSUInteger)pageIndex
{
    UIButton *sender = [_segmentBtns objectAtIndex:pageIndex];
    for (UIButton *btn in _segmentBtns) {
        btn.selected = NO;
    }
    sender.selected = YES;
    _indicatorView.center = CGPointMake(sender.center.x, 48);
    [_contentView setContentOffset:CGPointMake(_contentView.bounds.size.width*pageIndex, 0) animated:YES];
}

#pragma mark - IBAction methods

- (void)changePageAction:(UIButton *)sender
{
    NSInteger index = [_segmentBtns indexOfObject:sender];
    [self changePage:index];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_contentView]) {
        CGFloat offsetX= scrollView.contentOffset.x;
        NSUInteger pageIndex = offsetX/scrollView.bounds.size.width;
        [self changePage:pageIndex];
    }
}

@end
