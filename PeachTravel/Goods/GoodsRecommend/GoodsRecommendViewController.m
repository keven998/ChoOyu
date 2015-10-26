//
//  GoodsRecommendViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsRecommendViewController.h"
#import "GoodsRecommendTableViewCell.h"
#import "GoodsRecommendHeaderView.h"
#import "GoodsRecommendSectionHeaderView.h"

@interface GoodsRecommendViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) GoodsRecommendHeaderView *headerView;
@end

@implementation GoodsRecommendViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsRecommendTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsRecommendCell"];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _headerView = [GoodsRecommendHeaderView initViewFromNib];
    UIView *tempHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 210)];
    _tableView.tableHeaderView = tempHeaderView;
    [self.view addSubview:_headerView];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 210);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 173.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    GoodsRecommendSectionHeaderView *view = [GoodsRecommendSectionHeaderView initViewFromNib];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsRecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsRecommendCell" forIndexPath:indexPath];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_tableView]) {
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        CGRect frame = CGRectMake(0, 0-contentOffsetY, scrollView.bounds.size.width, 210);
        _headerView.frame = frame;
    }
}

@end
