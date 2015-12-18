//
//  MakeOrderTravelerInfoTableViewCell.m
//  
//
//  Created by liangpengshuai on 11/9/15.
//
//

#import "MakeOrderTravelerInfoTableViewCell.h"
#import "MakeOrderTravelerTableViewCell.h"
#import "OrderTravelerInfoModel.h"

@implementation MakeOrderTravelerInfoTableViewCell

+ (CGFloat)heightWithTravelerCount:(NSInteger)count
{
    return 50+44*count + 10;     //44: 标题高度  35:每个 cell 的高度，  10:footerView 的高度
}

- (void)awakeFromNib {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderTravelerTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderTravelerCell"];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 10)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setTravelerList:(NSMutableArray *)travelerList
{
    _travelerList = travelerList;
    if (_travelerList.count) {
        [_editTravelerButton setTitle:@"编辑" forState:UIControlStateNormal];
    } else {
        [_editTravelerButton setTitle:@"添加旅客信息" forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _travelerList.count;
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
    OrderTravelerInfoModel *travelerInfo = [_travelerList objectAtIndex:indexPath.section];
    MakeOrderTravelerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderTravelerCell" forIndexPath:indexPath];
    [cell.deleteBtn addTarget:self action:@selector(deleteTraveler:) forControlEvents:UIControlEventTouchUpInside];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@%@", travelerInfo.firstName, travelerInfo.lastName];
    cell.deleteBtn.tag = indexPath.section;
    cell.deleteBtn.hidden = YES;
    cell.spaceView.hidden = (indexPath.section == _travelerList.count-1);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)deleteTraveler:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定删除当前旅客？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [_travelerList removeObjectAtIndex:sender.tag];
            NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:sender.tag];
            [_tableView deleteSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
            [_delegate finishEditTravelerWithTravelerList:_travelerList];
        }
    }];
}

@end
