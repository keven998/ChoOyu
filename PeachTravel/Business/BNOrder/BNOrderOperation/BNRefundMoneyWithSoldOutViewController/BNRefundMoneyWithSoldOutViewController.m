//
//  BNRefundMoneyWithSoldOutViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNRefundMoneyWithSoldOutViewController.h"
#import "BNRefundMoneyRemarkTableViewCell.h"
#import "OrderManager+BNOrderManager.h"

@interface BNRefundMoneyWithSoldOutViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, strong)BNOrderDetailModel *orderDetail;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *currentTextActivity;
@property (nonatomic) CGPoint backupOffset;

@end

@implementation BNRefundMoneyWithSoldOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"缺货退款";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"BNRefundMoneyRemarkTableViewCell" bundle:nil] forCellReuseIdentifier:@"BNRefundMoneyRemarkTableViewCell"];
    
    [OrderManager asyncLoadBNOrderDetailWithOrderId:_orderId completionBlock:^(BOOL isSuccess, BNOrderDetailModel *orderDetail) {
        if (isSuccess) {
            self.orderDetail = orderDetail;
            [self setupToolBar];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupToolBar
{
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-55, kWindowWidth, 55)];
    toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolBar];

    UIButton *confirmRefundButton = [[UIButton alloc] initWithFrame:toolBar.bounds];
    [confirmRefundButton setTitle:@"确认退款" forState:UIControlStateNormal];
    [confirmRefundButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmRefundButton setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xFC4E27)] forState:UIControlStateNormal];
    confirmRefundButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [confirmRefundButton addTarget:self action:@selector(confirmRefundMoney:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:confirmRefundButton];
}

- (void)confirmRefundMoney:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入登录密码，完成退款" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            BNRefundMoneyRemarkTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            [OrderManager asyncBNRefuseRefundMoneyOrderWithOrderId:_orderId reason:nil leaveMessage:cell.remarkTextView.text completionBlock:^(BOOL isSuccess, NSString *errorStr) {
                if (isSuccess) {
                    [SVProgressHUD showHint:@"退款成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [SVProgressHUD showHint:@"退款失败，请重试"];
                }
            }];
        }
    }];
}

- (void)setOrderDetail:(BNOrderDetailModel *)orderDetail
{
    _orderDetail = orderDetail;
    [self.tableView reloadData];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _currentTextActivity = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _currentTextActivity = nil;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (!_currentTextActivity) {
        return;
    }
    _backupOffset = _tableView.contentOffset;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint textFieldPoint2View = [_currentTextActivity.superview convertPoint:_currentTextActivity.frame.origin toView:self.view];
    CGPoint keyboardPoint = CGPointMake(0, self.view.bounds.size.height-kbSize.height);
    CGPoint contentOffset = CGPointMake(0, _tableView.contentOffset.y+(textFieldPoint2View.y-keyboardPoint.y) + _currentTextActivity.bounds.size.height+10);
    
    [self.tableView setContentOffset:contentOffset animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (!_currentTextActivity) {
        return;
    }
    [self.tableView setContentOffset:_backupOffset animated:YES];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_orderDetail) {
        return 3;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.numberOfLines = 0;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"提示\n1.买家已经付款,您还未做任何处理.\n2.如果您想取消交易,可以退款给买家.\n3.您还可以发货"];
        [attr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0], NSForegroundColorAttributeName: COLOR_TEXT_I} range:NSMakeRange(0, 2)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;
        [attr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle}
                      range:NSMakeRange(0, attr.length)];

        cell.textLabel.textColor = COLOR_TEXT_II;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.attributedText = attr;
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.numberOfLines = 0;
        
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendFormat:@"买家: %ld\n", _orderDetail.consumerId];
        [content appendFormat:@"实付金额: %@\n", _orderDetail.formatPayPrice];
        if (_orderDetail.requestRefundtDate) {
            [content appendFormat:@"申请退款时间: %@\n", _orderDetail.requestRefundtDate];
        } else {
            [content appendFormat:@"申请退款时间: -\n"];
        }
        if (_orderDetail.requestRefundtExcuse) {
            [content appendFormat:@"申请退款原因: %@\n", _orderDetail.requestRefundtExcuse];
        } else {
            [content appendFormat:@"申请退款原因: -\n"];
        }
        if (_orderDetail.requestRefundtMessage) {
            [content appendFormat:@"申请退款留言: %@", _orderDetail.requestRefundtMessage];
        } else {
            [content appendFormat:@"申请退款留言: -"];
        }

        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;
        [attr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle}
                      range:NSMakeRange(0, attr.length)];
        
        cell.textLabel.textColor = COLOR_TEXT_II;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.attributedText = attr;
        return cell;
        
    } else {
        BNRefundMoneyRemarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNRefundMoneyRemarkTableViewCell" forIndexPath:indexPath];
        cell.priceLabel.text = [NSString stringWithFormat:@"退款金额: %@", _orderDetail.formatPayPrice];
        cell.remarkTextView.delegate = self;
        return cell;
    }
}

@end









