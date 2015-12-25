//
//  MakeOrderSelectPackageTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MakeOrderSelectPackageTableViewCell.h"
#import "MakeOrderPackageTableViewCell.h"
#import "GoodsPackageModel.h"

@interface MakeOrderSelectPackageTableViewCell ()

@property (nonatomic) NSInteger selectedIndex;     //当前选中的位置

@end

@implementation MakeOrderSelectPackageTableViewCell

+ (CGFloat)heightWithPackageList:(NSArray<GoodsPackageModel *> *)packageList
{
    CGFloat height = 44+12;
    for (GoodsPackageModel *packageModel in packageList) {
        height += [MakeOrderPackageTableViewCell heightWithPackageTitle:packageModel.packageName];
    }
    return height;     //44: 标题高度  35:每个 cell 的高度，  12:每个 footerview 的高度
}

- (void)awakeFromNib {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderPackageTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderPackageTableViewCell"];
    _selectedIndex = 0;      //默认选中第一个套餐
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
    GoodsPackageModel *package = [_packageList objectAtIndex:indexPath.section];
    return [MakeOrderPackageTableViewCell heightWithPackageTitle:package.packageName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MakeOrderPackageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderPackageTableViewCell" forIndexPath:indexPath];
    GoodsPackageModel *package = [_packageList objectAtIndex:indexPath.section];
    cell.packageTitle = package.packageName;
    cell.priceLabel.text = [NSString stringWithFormat:@"￥%@", package.formatCurrentPrice];
    cell.isSelected = (indexPath.section == _selectedIndex);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex = indexPath.section;
    if ([_deleagte respondsToSelector:@selector(didSelectedPackage:)]) {
        [_deleagte didSelectedPackage:[_packageList objectAtIndex:indexPath.section]];
    }
    [_tableView reloadData];
}




@end
