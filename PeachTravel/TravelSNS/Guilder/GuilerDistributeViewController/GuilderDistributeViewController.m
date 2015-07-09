//
//  GuilderDistributeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/23.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuilderDistributeViewController.h"
#import "GuilderTableViewController.h"
#import "GuiderCell.h"

@interface GuilderDistributeViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation GuilderDistributeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"派派达人";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 30, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = UITableViewCellSeparatorStyleNone;
        [self.tableView registerNib:[UINib nibWithNibName:@"GuiderCell" bundle:nil]  forCellReuseIdentifier:@"GuiderCell"];
        
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 232*CGRectGetWidth(self.view.frame)/414;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, CGRectGetWidth(self.view.bounds), 38)];
    if (section == 0) {
        sectionLabel.text = @"亚洲";
    } else if (section == 1) {
        sectionLabel.text = @"欧洲";
    } else if (section == 2) {
        sectionLabel.text = @"美洲";
    } else if (section == 3) {
        sectionLabel.text = @"大洋洲";
    } else if (section == 4) {
        sectionLabel.text = @"非洲";
    }
    
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    sectionLabel.textColor = APP_THEME_COLOR;
    sectionLabel.font = [UIFont systemFontOfSize:12];
    sectionLabel.tag = 1;
    [view addSubview:sectionLabel];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuiderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuiderCell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuilderTableViewController *guider = [[GuilderTableViewController alloc]init];
    [self.navigationController pushViewController:guider animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 44;
    CGPoint point;
    NSIndexPath *indexPath;
    point = scrollView.contentOffset;
    indexPath = [_tableView indexPathForRowAtPoint:point];
    if (indexPath.section == 0) {
        self.title = @"亚洲";
    } else if (indexPath.section == 1) {
        self.title = @"欧洲";
    } else if (indexPath.section == 2) {
        self.title = @"美洲";
    } else if (indexPath.section == 3) {
        self.title = @"大洋洲";
    } else if (indexPath.section == 4) {
        self.title = @"非洲";
    }
    
    if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        
    }
    else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
