//
//  LocalViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "LocalViewController.h"
#import "DMFilterView.h"
#import "SwipeView.h"
#import "LocalTableViewCell.h"

#define LOCAL_PAGE_TITLES       @[@"当地美食", @"Shopping", @"游玩", @"酒店"]
#define PAGE_FOOD               0
#define PAGE_SHOPPING           1
#define PAGE_FUN                2
#define PAGE_STAY               3

@interface LocalViewController ()<DMFilterViewDelegate, SwipeViewDataSource, SwipeViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) DMFilterView *filterView;
@property (nonatomic, strong) SwipeView *swipeView;

@property (nonatomic, strong) NSArray *dataPool;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我身边";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    _filterView = [[DMFilterView alloc]initWithStrings:LOCAL_PAGE_TITLES containerView:self.view];
    _filterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.filterView attachToContainerView];
    [self.filterView setDelegate:self];
    
    _swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, 64.0 + CGRectGetHeight(_filterView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64.0 - CGRectGetHeight(_filterView.frame))];
    _swipeView.dataSource = self;
    _swipeView.delegate = self;
    _swipeView.bounces = NO;
    _swipeView.backgroundColor = [UIColor redColor];
    _swipeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _swipeView.pagingEnabled = YES;
    _swipeView.itemsPerPage = 1;
    [self.view addSubview:_swipeView];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (_currentPage) {
//        case PAGE_FOOD:
//            
//            break;
//            
//        default:
//            break;
//    }
    return 185.0;
}


#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSArray *datas = [_dataPool objectAtIndex:_currentPage];
//    return datas.count;
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"local_cell"];
    cell.contentTypeFlag.image = [UIImage imageNamed:@"ic_gender_lady.png"];
    cell.contentTitle.text = @"美食街";
    cell.distance.text = @"999公里";
    cell.propertyView.text = @"¥9999/人";
    cell.standardImg.image = [UIImage imageNamed:@"ic_setting_avatar.png"];
    [cell.address setTitle:@"中关村大街中关村大街中关村大街中关村大街中关村大街中关村大街" forState:UIControlStateNormal];
    cell.commentAuthor.text = @"12344";
    cell.commentContent.text = @"不是很好吃而且东西还很贵";
    [cell.commentCount setTitle:@"999条" forState:UIControlStateNormal];
    [cell.ratingBar setValue:3.5];
    
//    NSArray *datas = [_dataPool objectAtIndex:_currentPage];
//    id item = [datas objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - SwipeViewDataSource
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return LOCAL_PAGE_TITLES.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UITableView *tbView = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tbView = [[UITableView alloc] initWithFrame:view.bounds];
        tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tbView.contentInset = UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0);
        tbView.dataSource = self;
        tbView.delegate = self;
        tbView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tbView.tag = 1;
        tbView.backgroundColor = APP_PAGE_COLOR;
        [view addSubview:tbView];
        
        [tbView registerNib:[UINib nibWithNibName:@"LocalTableViewCell" bundle:nil] forCellReuseIdentifier:@"local_cell"];
    }
    else
    {
        tbView = (UITableView *)[view viewWithTag:1];
    }
    
//    NSArray *data = [_dataPool objectAtIndex:index];
//    if (data == nil || data.count == 0) {
//        [self loadData];
//    } else {
        [tbView reloadData];
//    }
    
    return view;
}

- (void) loadData {
    
}


#pragma mark - SwipeViewDelegate

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    _currentPage = swipeView.currentPage;
    [_filterView setSelectedIndex:_currentPage];
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return swipeView.bounds.size;
}

#pragma mark - DMFilterViewDelegate

- (void)filterView:(DMFilterView *)filterView didSelectedAtIndex:(NSInteger)index {
    [_swipeView setCurrentPage:index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
