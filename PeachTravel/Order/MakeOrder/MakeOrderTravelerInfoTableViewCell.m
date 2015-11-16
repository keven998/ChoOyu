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
    return 44+44*count + 75;     //44: 标题高度  35:每个 cell 的高度，  65:footerView 的高度
}

- (void)awakeFromNib {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderTravelerTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderTravelerCell"];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 75)];
    _addTravelerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 35)];
    _addTravelerBtn.center = CGPointMake(footerView.bounds.size.width/2, footerView.bounds.size.height/2-5);
    [_addTravelerBtn setImage:[UIImage imageNamed:@"icon_makeOrder_addTraveler"] forState:UIControlStateNormal];
    [_addTravelerBtn setTitle:@"添加旅客" forState:UIControlStateNormal];
    [_addTravelerBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    _addTravelerBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    _addTravelerBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 3);
    _addTravelerBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _addTravelerBtn.layer.borderWidth = 0.5;
    _addTravelerBtn.layer.borderColor = APP_BORDER_COLOR.CGColor;
    [footerView addSubview:_addTravelerBtn];
    _tableView.tableFooterView = footerView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setTravelerList:(NSMutableArray *)travelerList
{
    _travelerList = travelerList;
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
    OrderTravelerInfoModel *travelerInfo = [_travelerList objectAtIndex:indexPath.row];
    MakeOrderTravelerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderTravelerCell" forIndexPath:indexPath];
    [cell.deleteBtn addTarget:self action:@selector(deleteTraveler:) forControlEvents:UIControlEventTouchUpInside];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@%@ %@:%@", travelerInfo.firstName, travelerInfo.lastName, travelerInfo.IDCategory, travelerInfo.IDNumber];
    cell.deleteBtn.tag = indexPath.section;
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
