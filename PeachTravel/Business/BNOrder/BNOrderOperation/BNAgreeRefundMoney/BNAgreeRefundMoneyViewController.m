//
//  BNAgreeRefundMoneyViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/14/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNAgreeRefundMoneyViewController.h"
#import "OrderManager+BNOrderManager.h"
#import "BNAgreeRefundMoneyRemarkTableViewCell.h"

@interface BNAgreeRefundMoneyViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate> {
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) UIView *currentTextActivity;
@property (nonatomic) CGPoint backupOffset;

@property (nonatomic, strong)BNOrderDetailModel *orderDetail;

@property (nonatomic) NSInteger refundCutdown;  //退款倒计时

@property (nonatomic) CGFloat refundMoney;  //退款金额
@property (nonatomic, copy, readonly) NSString *refundMoneyDesc;  //退款金额描述

@end

@implementation BNAgreeRefundMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"同意退款";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"BNAgreeRefundMoneyRemarkTableViewCell" bundle:nil] forCellReuseIdentifier:@"BNAgreeRefundMoneyRemarkTableViewCell"];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 55)];
    
    [self updateOrderDetail];
}

- (void)updateOrderDetail
{
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
    if (_toolBar.superview) {
        [_toolBar removeFromSuperview];
    }
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-55, kWindowWidth, 55)];
    _toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_toolBar];
    
    UIButton *confirmRefundButton = [[UIButton alloc] initWithFrame:_toolBar.bounds];
    [confirmRefundButton setTitle:@"确认退款" forState:UIControlStateNormal];
    [confirmRefundButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmRefundButton setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xFC4E27)] forState:UIControlStateNormal];
    confirmRefundButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [confirmRefundButton addTarget:self action:@selector(confirmRefundMoney:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:confirmRefundButton];
}

- (void)confirmRefundMoney:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入登录密码，完成退款" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        
    }];
}

- (void)setOrderDetail:(BNOrderDetailModel *)orderDetail
{
    _orderDetail = orderDetail;
    _refundMoney = _orderDetail.payPrice;
    if (_orderDetail.orderStatus == kOrderRefunding) {
        if (_orderDetail.expireTime - _orderDetail.currentTime > 0) {
            _refundCutdown = _orderDetail.refundLastTimeInterval - [[NSDate date] timeIntervalSince1970];
            if (timer) {
                [timer invalidate];
                timer = nil;
            }
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLeftTime) userInfo:nil repeats:YES];
        } else {
            _refundCutdown = 0;
            if (timer) {
                [timer invalidate];
                timer = nil;
            }
        }
        
    } else {
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    }
    [self.tableView reloadData];
}

- (void)updateLeftTime
{
    if (_refundCutdown == 0) {
        if (timer) {
            [timer invalidate];
            timer = nil;
            [self updateOrderDetail];
        }
        return;
    }
    --self.refundCutdown;
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    cell.textLabel.text = [self refundMoneyCutdownDesc];
}

- (NSString *)refundMoneyDesc
{
    NSString *priceStr;
    float currentPrice = round(_refundMoney*100)/100;
    if (!(currentPrice - (int)currentPrice)) {
        priceStr = [NSString stringWithFormat:@"%d", (int)currentPrice];
    } else {
        NSString *tempPrice = [NSString stringWithFormat:@"%.1f", currentPrice];
        if (!(_refundMoney - tempPrice.floatValue)) {
            priceStr = [NSString stringWithFormat:@"%.1f", currentPrice];
        } else {
            priceStr = [NSString stringWithFormat:@"%.2f", currentPrice];
        }
    }
    return priceStr;
}

- (NSString *)refundMoneyCutdownDesc
{
    NSInteger days = _refundCutdown/24/60/60;
    NSInteger hours = (_refundCutdown - days*24*3600)/3600;
    NSInteger minute = (_refundCutdown - days*24*3600 - hours*3600)/60;
    NSInteger second = (_refundCutdown - days*24*3600 - hours*3600 - minute*60);
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendFormat:@"自动退款倒计时"];
    if (days) {
        [str appendFormat:@"%ld天", days];
    }
    if (hours) {
        [str appendFormat:@"%ld小时", hours];
    }
    if (minute) {
        [str appendFormat:@"%ld分钟", minute];
    }
    if (second >= 0) {
        [str appendFormat:@"%ld秒 ", second];
    }
    [str appendString:@"内完成退款"];

    return str;
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
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
        return 4;
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
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.textColor = COLOR_TEXT_II;
        cell.textLabel.text = [self refundMoneyCutdownDesc];
        return cell;
        
    } else if (indexPath.section == 1) {
        if (_orderDetail.hasDeliverGoods) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.numberOfLines = 0;
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"提示\n1.您已发货，买家申请了退款。\n2.如果您同意退款，系统审核后，将钱款退还给买家。\n3.如果您拒绝退款，请输入拒绝原因，避免与买家发生交易冲突。\n4.如果您在买家申请退款后48小时未做处理，系统将自动退款给买家。"];
            [attr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0], NSForegroundColorAttributeName: COLOR_TEXT_I} range:NSMakeRange(0, 2)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 10;
            [attr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle}
                          range:NSMakeRange(0, attr.length)];
            
            cell.textLabel.textColor = COLOR_TEXT_II;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.attributedText = attr;
            return cell;
            
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.numberOfLines = 0;
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"提示\n1.买家已经付款,您还未做任何处理，买家申请了退款。\n2.如果您在买家申请退款后48小时未做处理，系统将自动退款给买家。\n3.如果您拒绝退款，您可以选择发货。"];
            [attr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0], NSForegroundColorAttributeName: COLOR_TEXT_I} range:NSMakeRange(0, 2)];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 10;
            [attr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle}
                          range:NSMakeRange(0, attr.length)];
            
            cell.textLabel.textColor = COLOR_TEXT_II;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.attributedText = attr;
            return cell;

        }
        
    } else if (indexPath.section == 2) {
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
        BNAgreeRefundMoneyRemarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNAgreeRefundMoneyRemarkTableViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = [NSString stringWithFormat:@"*退款说明"];
        cell.remarkTextView.delegate = self;
        return cell;
    }
}
@end
