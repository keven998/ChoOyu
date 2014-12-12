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
}

@end

@implementation TZTBViewController

- (id) init
{
    if ((self = [super init])) {
        _isLoadingMore = NO;
        _enableLoadingMore = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] init];
    _tableView.frame = self.view.bounds;
    _tableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
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
    if (_tableView.tableFooterView == nil) {
        _tableView.tableFooterView = self.footerView;
    }
    [_indicatroView startAnimating];
}

- (void) loadMoreCompleted {
    [_indicatroView stopAnimating];
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
    if (!_isLoadingMore && _enableLoadingMore) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < DEFAULT_FOOTER_HEIGHT) {
            [self beginLoadingMore];
        }
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
