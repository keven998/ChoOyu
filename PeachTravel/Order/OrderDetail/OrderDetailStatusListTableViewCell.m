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
    return 35*statusList.count;
}

- (void)awakeFromNib {
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"statusCell"];
    _tableView.dataSource = self;
    _tableView.delegate = self;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statusCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.textLabel.textColor = COLOR_TEXT_III;
    NSDictionary *statusDic = [_statusList objectAtIndex:indexPath.row];
    NSString *time = [statusDic objectForKey:@"time"];
    NSString *statusDesc = [statusDic objectForKey:@"status"];
    NSString *content = [NSString stringWithFormat:@"%@ %@", time, statusDesc];
    cell.textLabel.text = content;
    return cell;
}

@end
