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
    //    _selectedCityIndex = ;
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
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
    view.backgroundColor = APP_PAGE_COLOR;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 100, 40)];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = TEXT_COLOR_TITLE;
    [view addSubview:label];
    if (section == 0) {
        label.text = @"分类";
    } else {
        label.text = @"城市";
    }
    return view;
}
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0) {
//        return UITableViewCellAccessoryNone;
//    } else {
//        if(indexPath.row==_selectedCityIndex){
//            return UITableViewCellAccessoryCheckmark;
//        }
//        else{
//            return UITableViewCellAccessoryNone;
//        }
//    }
//    
//}

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
        [ctcell.segmentControl setSelectedSegmentIndex:_selectedCategoryIndex.row];
        [ctcell.segmentControl addTarget:self action:@selector(selectCategary:) forControlEvents:UIControlEventValueChanged];
        return ctcell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"select_cell" forIndexPath:indexPath];
        cell.textLabel.textColor = TEXT_COLOR_TITLE_DESC;
        cell.textLabel.text = [_contentItems objectAtIndex:indexPath.row];
        cell.tag = 100 + indexPath.row;
        if (indexPath.row == _selectedCityIndex.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    if (indexPath.section == 0) {
        return;
    } else {
        _selectedCityIndex = indexPath;
    }
    [tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - IBAction
- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectComplete {
    [self.delegate didSelectedcityIndex:_selectedCityIndex categaryIndex:_selectedCategoryIndex];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)selectCategary:(id)sender
{
    UISegmentedControl *switchButton = (UISegmentedControl*)sender;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:switchButton.selectedSegmentIndex inSection:0];
    _selectedCategoryIndex = ip;
    [self.tableView reloadData];
}

@end
