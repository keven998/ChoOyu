//
//  FilterViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/24.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "FilterViewController.h"
#import "CategoryTableViewCell.h"

@interface FilterViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"筛选";
    
    UIBarButtonItem *lbtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = lbtn;
    UIBarButtonItem *rbtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(selectComplete)];
    self.navigationItem.rightBarButtonItem = rbtn;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate  = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(-70, 0, 0, 0);
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 70)];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableView registerClass:[CategoryTableViewCell class] forCellReuseIdentifier:@"category_selection_cell"];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"select_cell"];
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 70)];
    view.backgroundColor = APP_PAGE_COLOR;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 100, 40)];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = TEXT_COLOR_TITLE;
    [view addSubview:label];
    if (section == 0) {
        label.text = @"分类";
    } else {
        label.text = @"城市";
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _contentItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CategoryTableViewCell *ctcell = [tableView dequeueReusableCellWithIdentifier:@"category_selection_cell" forIndexPath:indexPath];
        [ctcell setSelectedItems:[NSArray arrayWithObjects:@"景点", @"美食", @"购物", @"酒店", nil]];
        [ctcell.segmentControl setSelectedSegmentIndex:_selectedCategoryIndex];
        return ctcell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"select_cell" forIndexPath:indexPath];
        cell.textLabel.text = [_contentItems objectAtIndex:indexPath.row];
        if (_selectedCityIndex == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - IBAction
- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectComplete {
    
}
//- (void) selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath {
//    if (_filterType == FILTER_TYPE_CITY) {
//        if (_currentCityIndex == indexPath.row) {
//            return;
//        }
//        _cityName = str;
//        _currentCityIndex = indexPath.row;
//        [self resetContents];
//        [MobClick event:@"event_filter_city"];
//    } else if (_filterType == FILTER_TYPE_CATE) {
//        if (_currentListTypeIndex == indexPath.row) {
//            return;
//        }
//        _currentCategory = str;
//        _currentListTypeIndex = indexPath.row;
//        [MobClick event:@"event_filter_items"];
//        [self resetContents];
//    }
//}

//- (void) resetContents {
//    _isLoadingMoreNormal = YES;
//    _didEndScrollNormal = YES;
//    _enableLoadMoreNormal = NO;
//    CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
//    _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
//    [self.dataSource removeAllObjects];
//    [self.tableView reloadData];
//    _currentPageNormal = 0;
//    [self loadDataWithPageNo:_currentPageNormal];
//}


@end
