//
//  MakeOrderSelectPackageTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MakeOrderSelectPackageTableViewCell.h"
#import "MakeOrderPackageTableViewCell.h"

@implementation MakeOrderSelectPackageTableViewCell

+ (CGFloat)heightWithPackageCount:(int)count
{
    return 44+(35+12)*count;     //44: 标题高度  35:每个 cell 的高度，  12:每个 footerview 的高度
}

- (void)awakeFromNib {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderPackageTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderPackageTableViewCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setPackageList:(NSArray *)packageList
{
    _packageList = packageList;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _packageList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MakeOrderPackageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderPackageTableViewCell" forIndexPath:indexPath];
    cell.packageTitle = @"商品套餐";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}




@end
