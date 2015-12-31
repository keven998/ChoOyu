//
//  OrderDetailStatusListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/31/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailStatusListTableViewCell.h"

@implementation OrderDetailStatusListTableViewCell

+ (CGFloat)heightOfCellWithStatusList:(NSArray *)statusList
{
    return 40*statusList.count;
}

- (void)awakeFromNib {
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"statusCell"];
}

- (void)setStatusList:(NSArray *)statusList
{
    _statusList = statusList;
    [_tableView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _statusList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statusCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
