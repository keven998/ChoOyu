//
//  OrderDetailTravelerPreviewTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/24/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailTravelerPreviewTableViewCell.h"
#import "TravelerListTableViewCell.h"

@interface OrderDetailTravelerPreviewTableViewCell () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation OrderDetailTravelerPreviewTableViewCell

+ (CGFloat)heightOfCellWithTravelerList:(NSArray *)travelerList
{
    return 50 + travelerList.count*130;
}

- (void)awakeFromNib {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"TravelerListTableViewCell" bundle:nil] forCellReuseIdentifier:@"travelerListCell"];
}

- (void)setTravelerList:(NSArray *)travelerList
{
    _travelerList = travelerList;
    _titleLabel.text = [NSString stringWithFormat:@"旅客信息 (%ld)", _travelerList.count];
    [self.tableView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _travelerList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderTravelerInfoModel *travelerInfo = _travelerList[indexPath.row];
    TravelerListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travelerListCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.numberLabel.text = [NSString stringWithFormat:@"旅客%ld", indexPath.row+1];
    cell.travelerInfo = travelerInfo;
    
    return cell;
}

@end
