//
//  AskRefundMoneyViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "AskRefundMoneyViewController.h"
#import "OrderManager.h"
#import "AskRefundMoneyTableViewCell.h"
#import "AskRefundMoneyLeaveMessageTableViewCell.h"
#import "OrderDetailViewController.h"

@interface AskRefundMoneyViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *refundExcuseList;
@property (nonatomic) NSInteger selectIndex;
@property (nonatomic, copy) NSString *leaveMessage;

@end

@implementation AskRefundMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"申请退款";
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"AskRefundMoneyTableViewCell" bundle:nil] forCellReuseIdentifier:@"askRefundMoneyCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"AskRefundMoneyLeaveMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"askRefundMoneyLeaveMessageCell"];

    _refundExcuseList = @[@"我想重新下单", @"我的旅行计划有所改变", @"我不想体验这个游玩项目了", @"我想在别家购买类似的游玩项目", @"其它"];
    _selectIndex = 0;
    
    UIButton *confirmRequestBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    [confirmRequestBtn setTitle:@"提交申请" forState:UIControlStateNormal];
    [confirmRequestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmRequestBtn addTarget:self action:@selector(confirmRequest:) forControlEvents:UIControlEventTouchUpInside];
    [confirmRequestBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [self.view addSubview:confirmRequestBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)confirmRequest:(UIButton *)btn
{
    [OrderManager asyncRequestRefundMoneyWithOrderId:_orderDetail.orderId reason:[_refundExcuseList objectAtIndex:_selectIndex] leaveMessage:_leaveMessage completionBlock:^(BOOL isSuccess, NSString *error) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"申请退款成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOrderdetailNoti object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [SVProgressHUD showHint:@"申请退款失败"];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _refundExcuseList.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 35;
    }
    return 140;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 60;
    }
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 60)];
        sectionHeader.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, 150, 50)];
        label.text = @"退款原因";
        label.textColor = COLOR_TEXT_I;
        label.font = [UIFont systemFontOfSize:15.0];
        [sectionHeader addSubview:label];
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, sectionHeader.bounds.size.width, 0.5)];
        spaceView.backgroundColor = COLOR_LINE;
        [sectionHeader addSubview:spaceView];
        return sectionHeader;
        
    } else {
        UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50)];
        sectionHeader.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, 150, 50)];
        label.text = @"留言";
        label.textColor = COLOR_TEXT_I;
        label.font = [UIFont systemFontOfSize:15.0];
        [sectionHeader addSubview:label];
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionHeader.bounds.size.width, 0.5)];
        spaceView.backgroundColor = COLOR_LINE;
        [sectionHeader addSubview:spaceView];
        return sectionHeader;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        AskRefundMoneyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"askRefundMoneyCell" forIndexPath:indexPath];
        cell.titleLabel.text = _refundExcuseList[indexPath.row];
        cell.selectButton.selected = (indexPath.row == _selectIndex);
        return cell;
    } else {
        AskRefundMoneyLeaveMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"askRefundMoneyLeaveMessageCell" forIndexPath:indexPath];
        cell.contentTextView.delegate = self;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        _selectIndex = indexPath.row;
        [self.tableView reloadData];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    CGPoint point = [cell convertPoint:CGPointZero toView:self.tableView];
    [_tableView setContentOffset:CGPointMake(0, point.y-64-50) animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        _leaveMessage = textView.text;
        [_tableView setContentOffset:CGPointZero];
        return NO;
    }
    return YES;
}

@end
