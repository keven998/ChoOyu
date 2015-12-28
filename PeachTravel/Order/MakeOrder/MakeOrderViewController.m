//
//  MakeOrderViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MakeOrderViewController.h"
#import "MakeOrderTitleTableViewCell.h"
#import "MakeOrderSelectDateTableViewCell.h"
#import "MakeOrderSelectPackageTableViewCell.h"
#import "MakeOrderSelectCountTableViewCell.h"
#import "MakeOrderTravelerInfoTableViewCell.h"
#import "MakeOrderContactInfoTableViewCell.h"
#import "SuperWebViewController.h"
#import "PDTSimpleCalendarViewController.h"
#import "SelectTravelerListViewController.h"
#import "OrderDetailModel.h"
#import "OrderManager.h"
#import "OrderDetailPreviewViewController.h"
#import "DialCodeTableViewController.h"
#import "MakeOrderUnitPriceTableViewCell.h"


@interface MakeOrderViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, MakeOrderEditTravelerInfoDelegate, PDTSimpleCalendarViewDelegate, MakeOrderSelectPackageDelegate, MakeOrderSelectCountDelegate, TravelerInfoListDelegate, DialCodeTableViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *totalPriceLabel;
@property (nonatomic, strong) UIButton *commintOrderBtn;
@property (nonatomic, strong) UIView *currentTextActivity;
@property (nonatomic) CGPoint backupOffset;
@property (nonatomic, strong) OrderDetailModel *orderDetail;

@end

@implementation MakeOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _orderDetail = [[OrderDetailModel alloc] init];
    _orderDetail.orderContact = [[OrderTravelerInfoModel    alloc] init];
    _orderDetail.goods = _goodsModel;
    _orderDetail.count = 1;
    _orderDetail.selectedPackage = [_goodsModel.packages firstObject];
    _orderDetail.travelerList = [[NSArray alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsSelection = NO;
    _tableView.separatorColor = APP_BORDER_COLOR;
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderTitleTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderTitleTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderSelectPackageTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderSelectPackageCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderSelectDateTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderSelectDataCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderSelectCountTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderSelectCountCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderTravelerInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderTravelerEditCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderContactInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderContactInfoCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderUnitPriceTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderUnitPriceTableViewCell"];
    
    self.navigationItem.title = @"订单填写";
    [self.view addSubview:_tableView];
    [self setupToolbar];
    [self setupTableViewFooterView];
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

- (void)setupTableViewFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 56+50)];
    footerView.backgroundColor = APP_PAGE_COLOR;
    _tableView.tableFooterView = footerView;
    
    UIButton *checkBox = [[UIButton alloc] initWithFrame:CGRectMake(11, 18, 13, 13)];
    [checkBox setImage:[UIImage imageNamed:@"icon_makeOrder_checkBox_normal"] forState:UIControlStateNormal];
    [checkBox setImage:[UIImage imageNamed:@"icon_makeOrder_checkBox_selected"] forState:UIControlStateSelected];
    checkBox.selected = YES;
    [footerView addSubview:checkBox];
    UITextView *agreementTextView = [[UITextView alloc] initWithFrame:CGRectMake(30, 10, 200, 30)];
    agreementTextView.backgroundColor = [UIColor clearColor];
    agreementTextView.delegate = self;
    agreementTextView.editable = NO;
    agreementTextView.scrollEnabled = NO;
    agreementTextView.textColor = COLOR_TEXT_III;
    agreementTextView.linkTextAttributes = @{NSForegroundColorAttributeName:APP_THEME_COLOR};

    agreementTextView.font = [UIFont systemFontOfSize:14];
    NSMutableAttributedString *agreementStr = [[NSMutableAttributedString alloc] initWithString:@"我已阅读并同意《旅行派条款》"];
    [agreementStr addAttributes:@{NSLinkAttributeName: [NSURL URLWithString:@"http://www.lvxingpai.cn"]} range:NSMakeRange(7, 7)];
    agreementTextView.attributedText = agreementStr;
    [footerView addSubview:agreementTextView];
    
}
- (void)setupToolbar
{
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-56, self.view.bounds.size.width, 56)];
    toolBar.backgroundColor = UIColorFromRGB(0xcccccc);
    [self.view addSubview:toolBar];
    
    _totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 16, 200, 25)];
    _totalPriceLabel.textColor = [UIColor redColor];
    _totalPriceLabel.font = [UIFont systemFontOfSize:17.0];
    _totalPriceLabel.text = [NSString stringWithFormat:@"￥%@", _orderDetail.formatTotalPrice];
    [toolBar addSubview:_totalPriceLabel];
    
    _commintOrderBtn = [[UIButton alloc] initWithFrame:CGRectMake(toolBar.bounds.size.width-toolBar.bounds.size.width/5*2, 0, toolBar.bounds.size.width/5*2, 56)];
    [_commintOrderBtn addTarget:self action:@selector(commintOrder:) forControlEvents:UIControlEventTouchUpInside];
    [_commintOrderBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xff6633)] forState:UIControlStateNormal];
    [_commintOrderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _commintOrderBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [_commintOrderBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [toolBar addSubview:_commintOrderBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)choseLeftDate:(UIButton *)sender
{
    PDTSimpleCalendarViewController *ctl = [[PDTSimpleCalendarViewController alloc] init];
    [ctl setDelegate:self];
    ctl.weekdayHeaderEnabled = YES;
    ctl.priceList = _orderDetail.selectedPackage.priceList;
    if ([NSDate date].timeIntervalSince1970 > _orderDetail.selectedPackage.startPriceDate.timeIntervalSince1970) {
        ctl.firstDate = [NSDate date];
    } else {
        ctl.firstDate = _orderDetail.selectedPackage.startPriceDate;
    }
    
    ctl.lastDate = _orderDetail.selectedPackage.endPriceDate;
    ctl.weekdayTextType = PDTSimpleCalendarViewWeekdayTextTypeVeryShort;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_orderDetail.useDate];
    ctl.selectedDate = date;

    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)addTraveler:(UIButton *)sender
{
    SelectTravelerListViewController *ctl = [[SelectTravelerListViewController alloc] init];
    ctl.delegate = self;
    ctl.canMultipleSelect = YES;
    ctl.canEditInfo = YES;
    ctl.selectedTravelers = [_orderDetail.travelerList mutableCopy];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)choseDialCode:(id)sender
{
    DialCodeTableViewController *ctl = [[DialCodeTableViewController alloc] init];
    ctl.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:ctl];
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)selectTravelerAsContactAction:(UIButton *)sender
{
    SelectTravelerListViewController *ctl = [[SelectTravelerListViewController alloc] init];
    ctl.delegate = self;
    ctl.canMultipleSelect = NO;
    ctl.canEditInfo = NO;
    NSMutableArray *selectTraveler = [[NSMutableArray alloc] init];
    if (_orderDetail.orderContact) {
        [selectTraveler addObject:_orderDetail.orderContact];
    }
    ctl.selectedTravelers = selectTraveler;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)commintOrder:(UIButton *)sender
{
    NSString *errorStr = [OrderManager checkOrderIsCompleteWhenMakeOrder:_orderDetail];
    if (errorStr) {
        [SVProgressHUD showHint:errorStr];
        return;
    }
    NSMutableArray *travelerIds = [[NSMutableArray alloc] init];
    for (OrderTravelerInfoModel *traveler in _orderDetail.travelerList) {
        [travelerIds addObject:traveler.uid];
    }
    
    OrderDetailPreviewViewController *ctl = [[OrderDetailPreviewViewController alloc] init];
    ctl.orderDetail = _orderDetail;
    ctl.orderId = _orderDetail.orderId;
    ctl.travelerIdList = travelerIds;
    [self.navigationController pushViewController:ctl animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 72.5;
    } else if (indexPath.row == 1) {
        return [MakeOrderSelectPackageTableViewCell heightWithPackageList:_orderDetail.goods.packages];
    } else if (indexPath.row == 5) {
        return [MakeOrderTravelerInfoTableViewCell heightWithTravelerCount:_orderDetail.travelerList.count];
    } else if (indexPath.row == 6) {
        return 320;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        MakeOrderTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderTitleTableViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = _goodsModel.goodsName;
        return cell;
        
    } else if (indexPath.row == 1) {
        MakeOrderSelectPackageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderSelectPackageCell" forIndexPath:indexPath];
        cell.packageList = _goodsModel.packages;
        cell.deleagte = self;
        return cell;
        
    } else if (indexPath.row == 2) {
        MakeOrderSelectDateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderSelectDataCell" forIndexPath:indexPath];
        cell.dateLabel.text = _orderDetail.useDateStr;
        [cell.choseDateBtn addTarget:self action:@selector(choseLeftDate:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    } else if (indexPath.row == 3) {
        MakeOrderSelectCountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderSelectCountCell" forIndexPath:indexPath];
        cell.count = _orderDetail.count;
        cell.delegate = self;
        return cell;
        
    } else if (indexPath.row == 4) {
        MakeOrderUnitPriceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderUnitPriceTableViewCell" forIndexPath:indexPath];
        cell.priceLabel.text = [NSString stringWithFormat:@"￥%@", _orderDetail.formatUnitPrice];
        return cell;
        
    } else if (indexPath.row == 5) {
        MakeOrderTravelerInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderTravelerEditCell" forIndexPath:indexPath];
        cell.travelerList = [_orderDetail.travelerList mutableCopy];
        cell.delegate = self;
        [cell.editTravelerButton addTarget:self action:@selector(addTraveler:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    } else if (indexPath.row == 6) {
        MakeOrderContactInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderContactInfoCell" forIndexPath:indexPath];
        [cell.selectTravelerBtn addTarget:self action:@selector(selectTravelerAsContactAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.dialCodeButton addTarget:self action:@selector(choseDialCode:) forControlEvents:UIControlEventTouchUpInside];
        cell.lastNameTextField.delegate = self;
        cell.telTextField.delegate = self;
        cell.firstNameTextField.delegate = self;
        cell.messageTextView.delegate = self;
        return cell;
    }
    return nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        MakeOrderContactInfoTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:6 inSection:0]];
        if ([textField isEqual:cell.lastNameTextField]) {
            [cell.firstNameTextField becomeFirstResponder];
        } else  if ([textField isEqual:cell.firstNameTextField]) {
            [cell.telTextField becomeFirstResponder];
        } else  if ([textField isEqual:cell.telTextField]) {
            [cell.messageTextView becomeFirstResponder];
        }
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentTextActivity = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!_orderDetail.orderContact) {
        _orderDetail.orderContact = [[OrderTravelerInfoModel alloc] init];
        _orderDetail.orderContact.dialCode = @"86";
    }
    MakeOrderContactInfoTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:6 inSection:0]];
    if ([textField isEqual:cell.lastNameTextField]) {
        _orderDetail.orderContact.lastName = textField.text;
    } else  if ([textField isEqual:cell.firstNameTextField]) {
        _orderDetail.orderContact.firstName = textField.text;
    } else  if ([textField isEqual:cell.telTextField]) {
        _orderDetail.orderContact.telNumber = textField.text;
    }
}

#pragma mark = UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    _orderDetail.leaveMessage = textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    _currentTextActivity = textView;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"旅行派条款";
    webCtl.urlStr = URL.absoluteString;
    [self.navigationController pushViewController:webCtl animated:YES];
    return NO;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
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
    [self.tableView setContentOffset:_backupOffset animated:YES];
}

#pragma mark - MakeOrderEditTravelerInfoDelegate

- (void)finishEditTravelerWithTravelerList:(NSArray *)travelerList
{
    _orderDetail.travelerList = travelerList;
    [self.tableView reloadData];
}

#pragma mark - MakeOrderSelectPackageDelegate

- (void)didSelectedPackage:(GoodsPackageModel *)package
{
    if (![package.packageId isEqualToString:_orderDetail.selectedPackage.packageId]) {
        [OrderManager updateOrder:_orderDetail WithGoodsPackage:package];
        _orderDetail.unitPrice = 0;
        BOOL find = NO;
        for (NSDictionary *priceDic in package.priceList) {
            NSTimeInterval startDate = [[[priceDic objectForKey:@"timeRange"] firstObject] integerValue]/1000;
            NSTimeInterval endDate = [[[priceDic objectForKey:@"timeRange"] lastObject] integerValue]/1000;
            if (_orderDetail.useDate>startDate && _orderDetail.useDate<endDate) {
                _orderDetail.unitPrice = [[priceDic objectForKey:@"price"] floatValue];
                find = YES;
                break;
            }
        }
        if (!find) {
            _orderDetail.useDate = 0;
        }
        _totalPriceLabel.text = [NSString stringWithFormat:@"￥%@", _orderDetail.formatTotalPrice];
        [self.tableView reloadData];
    }
}

- (void)finishSelectTravelers:(NSArray<OrderTravelerInfoModel *> *)travelerList
{
    _orderDetail.travelerList = travelerList;
    [_tableView reloadData];
}

- (void)finishSelectTraveler:(OrderTravelerInfoModel *)selectTraveler
{
    MakeOrderContactInfoTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:6 inSection:0]];
    _orderDetail.orderContact = selectTraveler;
    cell.firstNameTextField.text = selectTraveler.firstName;
    cell.lastNameTextField.text = selectTraveler.lastName;
    cell.telTextField.text = selectTraveler.telNumber;
    [cell.dialCodeButton setTitle:[NSString stringWithFormat:@"+%@", selectTraveler.dialCode] forState:UIControlStateNormal];
}

#pragma mark - MakeOrderSelectCountDelegate

- (void)updateSelectCount:(NSInteger)count
{
    [OrderManager updateOrder:_orderDetail WithBuyCount:count];
    _totalPriceLabel.text = [NSString stringWithFormat:@"￥%@", _orderDetail.formatTotalPrice];
}

#pragma mark - PDTSimpleCalendarViewDelegate

- (void)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller didSelectDate:(NSDate *)date price:(float)price
{
    _orderDetail.unitPrice = price;
    _orderDetail.useDate = date.timeIntervalSince1970;
    _totalPriceLabel.text = [NSString stringWithFormat:@"￥%@", _orderDetail.formatTotalPrice];
    [_tableView reloadData];
}


#pragma mark - DialCodeTableViewControllerDelegate

- (void)didSelectDialCode:(NSDictionary *)dialCode
{
    if (dialCode) {
        MakeOrderContactInfoTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:6 inSection:0]];

        [cell.dialCodeButton setTitle:[NSString stringWithFormat:@"+%@", [dialCode objectForKey:@"dialCode"]] forState:UIControlStateNormal];
        
        if (!_orderDetail.orderContact) {
            _orderDetail.orderContact = [[OrderTravelerInfoModel alloc] init];
        }

        _orderDetail.orderContact.dialCode = [dialCode objectForKey:@"dialCode"];
    }
}


@end