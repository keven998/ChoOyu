//
//  SelectionTableViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/3.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "SelectionTableViewController.h"

@interface SelectionTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *selectTableView;

@end

@implementation SelectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = _titleTxt;
    UIBarButtonItem *lbtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = lbtn;
    if (!_selectItemIndex&&_selectItemIndex != 0){
    _selectItemIndex = [_contentItems indexOfObject:_selectItem];
    }
    _selectTableView.backgroundColor = APP_PAGE_COLOR;
    _selectTableView.separatorColor = APP_BORDER_COLOR;
    [_selectTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"select_cell"];
}

#pragma mark - IBAction
- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contentItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"select_cell" forIndexPath:indexPath];
    cell.textLabel.text = [_contentItems objectAtIndex:indexPath.row];
    if (_selectItemIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 18;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil) {
        [self.delegate selectItem:[_contentItems objectAtIndex:indexPath.row] atIndex:indexPath];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
