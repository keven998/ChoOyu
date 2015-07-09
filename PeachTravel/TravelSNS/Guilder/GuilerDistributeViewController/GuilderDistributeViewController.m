//
//  GuilderDistributeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/23.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuilderDistributeViewController.h"
#import "GuiderCollectionViewController.h"
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
    
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.tableView registerNib:[UINib nibWithNibName:@"GuiderCell" bundle:nil]  forCellReuseIdentifier:@"GuiderCell"];
        
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 699/3;
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
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    if (section == 0) {
        sectionLabel.text = @"美国";
    } else if (section == 1) {
        sectionLabel.text = @"中国";
    } else if (section == 2) {
        sectionLabel.text = @"澳大利亚";
    } else if (section == 3) {
        sectionLabel.text = @"加拿大";
    } else if (section == 4) {
        sectionLabel.text = @"赤道几内亚";
    }
    
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    sectionLabel.textColor = APP_THEME_COLOR;
    sectionLabel.font = [UIFont systemFontOfSize:11];
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
    GuiderCollectionViewController *guider = [[GuiderCollectionViewController alloc] initWithNibName:@"GuiderCollectionViewController" bundle:nil];
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
        self.title = @"美国";
    } else if (indexPath.section == 1) {
        self.title = @"中国";
    } else if (indexPath.section == 2) {
        self.title = @"澳大利亚";
    } else if (indexPath.section == 3) {
        self.title = @"加拿大";
    } else if (indexPath.section == 4) {
        self.title = @"赤道几内亚";
    }
    
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
@end
