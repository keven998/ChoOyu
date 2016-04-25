//
//  PTMakeSelectContentTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTMakeSelectContentTableViewController.h"

@interface PTMakeSelectContentTableViewController ()

@end

@implementation PTMakeSelectContentTableViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.navigationController.childViewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dismiss)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 48, 30)];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(comfirmSelect)];

    if (_isSelectTopic) {
        self.navigationItem.title = @"主题偏向";
        self.dataSource = @[@"蜜月度假", @"家庭亲子", @"美食购物", @"人文探险", @"户外体验"];
    } else {
        self.navigationItem.title = @"服务包含";
        self.dataSource = @[@"机票酒店", @"美食门票", @"导游接机", @"行程设计", @"全套服务"];
    }
}

- (NSMutableArray *)selectContentList
{
    if (!_selectContentList) {
        _selectContentList = [[NSMutableArray alloc] init];
    }
    return _selectContentList;
}

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)comfirmSelect
{
    if (_isSelectTopic) {
        [_delegate didSelectTopicContent:_selectContentList];
    } else {
        [_delegate didSelectServiceContent:_selectContentList];
    }
    [self dismiss];
}

- (void)dismiss
{
    if (self.navigationController.childViewControllers.count <= 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)selectAction:(UIButton *)sender
{
    if (sender.selected) {
        [self.selectContentList removeObjectAtIndex:sender.tag];
    } else {
        [self.selectContentList addObject:[_dataSource objectAtIndex:sender.tag]];
    }
    sender.selected = !sender.selected;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [button setImage:[UIImage imageNamed:@"icon_circle_normal"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"icon_circle_selected"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    UIButton *selectButton = (UIButton *)cell.accessoryView;
    selectButton.tag = indexPath.row;
    cell.textLabel.text = [_dataSource objectAtIndex:indexPath.row];
    selectButton.selected = NO;
    for (NSString *content in _selectContentList) {
        if ([content isEqualToString:[_dataSource objectAtIndex:indexPath.row]]) {
            selectButton.selected = YES;
            return cell;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)cell.accessoryView;
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
