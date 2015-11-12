//
//  TravelerInfoListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/10/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "TravelerInfoListViewController.h"
#import "TravelerInfoTableViewCell.h"

@interface TravelerInfoListViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation TravelerInfoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"TravelerInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"travelerInfoTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TravelerInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travelerInfoTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = @"小琴";
    cell.subTitleLabel.text = @"身份证: 21312312312312";
    return cell;
}

@end
