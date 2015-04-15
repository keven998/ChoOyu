//
//  TZTBViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/12.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "TZTBViewController.h"

#define DEFAULT_FOOTER_HEIGHT 44.0

@interface TZTBViewController ()<UITableViewDelegate, UITableViewDataSource> {
    UIActivityIndicatorView *_indicatroView;
    BOOL isSameScrollProcessEnd;
}

@end

@implementation TZTBViewController

- (id) init
{
    if ((self = [super init])) {
        _isLoadingMore = NO;
        _enableLoadingMore = YES;
        isSameScrollProcessEnd = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToAllPets)];
//    [backBtn setImage:[UIImage imageNamed:@"ic_navigation_back"]];
//    self.navigationItem.leftBarButtonItem = backBtn;
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBackToAllPets)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 48, 30)];
    //[button setTitle:@"返回" forState:UIControlStateNormal];
//    [button setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
//    [button setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
//    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
//    button.titleEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.tableView = [[UITableView alloc] init];
    _tableView.frame = self.view.bounds;
    _tableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)goBackToAllPets
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.bounds), DEFAULT_FOOTER_HEIGHT)];
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _footerView.backgroundColor = APP_PAGE_COLOR;
        
        _indicatroView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)];
        [_indicatroView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_footerView addSubview:_indicatroView];
        [_indicatroView setCenter:CGPointMake(CGRectGetWidth(_tableView.bounds)/2.0, DEFAULT_FOOTER_HEIGHT/2.0)];
    }
    return _footerView;
}

- (void) beginLoadingMore {
    _isLoadingMore = YES;
    if (_tableView.tableFooterView == nil) {
        _tableView.tableFooterView = self.footerView;
    }
    [_indicatroView startAnimating];
}

- (void) loadMoreCompleted {
    if (!_isLoadingMore) return;
    [_indicatroView stopAnimating];
    _isLoadingMore = NO;
}

- (void) setFooterViewVisibility:(BOOL)visible {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_isLoadingMore && _enableLoadingMore && isSameScrollProcessEnd) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < DEFAULT_FOOTER_HEIGHT) {
            isSameScrollProcessEnd = NO;
            [self beginLoadingMore];
        }
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isSameScrollProcessEnd = YES;
}


#pragma mark - UITableViewDelegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
}

@end
