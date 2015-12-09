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
#import "OrderDetailViewController.h"

@interface MakeOrderViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, MakeOrderEditTravelerInfoDelegate, PDTSimpleCalendarViewDelegate, MakeOrderSelectPackageDelegate, MakeOrderSelectCountDelegate, TravelerInfoListDelegate>

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
    _orderDetail.orderContact = [[OrderContactInfoModel alloc] init];
    _orderDetail.goods = _goodsModel;
    _orderDetail.count = 1;
    _orderDetail.selectedPackage = [_goodsModel.packages firstObject];
    _orderDetail.totalPrice = [OrderManager orderTotalPrice:_orderDetail];
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
    NSMutableAttributedString *agreementStr = [[NSMutableAttributedString alloc] initWithString:@"我已阅读并同意《旅行拍条款》"];
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
    _totalPriceLabel.textColor = [UIColor whiteColor];
    _totalPriceLabel.font = [UIFont systemFontOfSize:17.0];
    _totalPriceLabel.text = [NSString stringWithFormat:@"%d", (int)_orderDetail.totalPrice];
    [toolBar addSubview:_totalPriceLabel];
    
    _commintOrderBtn = [[UIButton alloc] initWithFrame:CGRectMake(toolBar.bounds.size.width-toolBar.bounds.size.width/5*2, 0, toolBar.bounds.size.width/5*2, 56)];
    [_commintOrderBtn addTarget:self action:@selector(commintOrder:) forControlEvents:UIControlEventTouchUpInside];
    [_commintOrderBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xff6633)] forState:UIControlStateNormal];
    [_commintOrderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _commintOrderBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [_commintOrderBtn setTitle:@"提交订单" forState:UIControlStateNormal];
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
    ctl.firstDate = _orderDetail.selectedPackage.startPriceDate;
    ctl.lastDate = _orderDetail.selectedPackage.endPriceDate;
    ctl.weekdayTextType = PDTSimpleCalendarViewWeekdayTextTypeVeryShort;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)addTraveler:(UIButton *)sender
{
    SelectTravelerListViewController *ctl = [[SelectTravelerListViewController alloc] init];
    ctl.delegate = self;
    ctl.selectedTravelers = [_orderDetail.travelerList mutableCopy];
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
    
    [OrderManager asyncMakeOrderWithGoodsId:_orderDetail.goods.goodsId travelers:travelerIds packageId:_orderDetail.selectedPackage.packageId playDate:_orderDetail.useDate quantity:_orderDetail.count contactPhone:_orderDetail.orderContact.tel.integerValue contactFirstName:_orderDetail.orderContact.firstName contactLastName:_orderDetail.orderContact.lastName leaveMessage:_orderDetail.leaveMessage completionBlock:^(BOOL isSuccess, OrderDetailModel *orderDetail) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"订单创建成功"];
            _orderDetail = orderDetail;
            OrderDetailViewController *ctl = [[OrderDetailViewController alloc] init];
            ctl.orderDetail = _orderDetail;
            ctl.orderId = _orderDetail.orderId;
            NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
            [controllers replaceObjectAtIndex:controllers.count-1 withObject:ctl];
            [self.navigationController setViewControllers:controllers animated:YES];
        } else {
            [SVProgressHUD showHint:@"订单创建失败"];
        }
    }];
   
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
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
        return [MakeOrderSelectPackageTableViewCell heightWithPackageCount:_orderDetail.goods.packages.count];
    } else if (indexPath.row == 4) {
        return [MakeOrderTravelerInfoTableViewCell heightWithTravelerCount:_orderDetail.travelerList.count];
    } else if (indexPath.row == 5) {
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
        MakeOrderTravelerInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderTravelerEditCell" forIndexPath:indexPath];
        cell.travelerList = [_orderDetail.travelerList mutableCopy];
        cell.delegate = self;
        [cell.editTravelerButton addTarget:self action:@selector(addTraveler:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    } else if (indexPath.row == 5) {
        MakeOrderContactInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderContactInfoCell" forIndexPath:indexPath];
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
        MakeOrderContactInfoTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:5 inSection:0]];
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
    MakeOrderContactInfoTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:5 inSection:0]];
    if ([textField isEqual:cell.lastNameTextField]) {
        _orderDetail.orderContact.lastName = textField.text;
    } else  if ([textField isEqual:cell.firstNameTextField]) {
        _orderDetail.orderContact.firstName = textField.text;
    } else  if ([textField isEqual:cell.telTextField]) {
        _orderDetail.orderContact.tel = textField.text;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    _orderDetail.leaveMessage = textView.text;

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
    [OrderManager updateOrder:_orderDetail WithGoodsPackage:package];
    _orderDetail.totalPrice = [OrderManager orderTotalPrice:_orderDetail];
    _totalPriceLabel.text = [NSString stringWithFormat:@"%d", (int)_orderDetail.totalPrice];
}

- (void)finishSelectTraveler:(NSArray<OrderTravelerInfoModel *> *)travelerList
{
    _orderDetail.travelerList = travelerList;
    [_tableView reloadData];
}

#pragma mark - MakeOrderSelectCountDelegate

- (void)updateSelectCount:(NSInteger)count
{
    [OrderManager updateOrder:_orderDetail WithBuyCount:count];
    _orderDetail.totalPrice = [OrderManager orderTotalPrice:_orderDetail];
    _totalPriceLabel.text = [NSString stringWithFormat:@"%d", (int)_orderDetail.totalPrice];
}

#pragma mark - PDTSimpleCalendarViewDelegate

- (void)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller didSelectDate:(NSDate *)date
{
//    NSString *dateStr =   [ConvertMethods dateToString:date withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
    _orderDetail.useDate = date.timeIntervalSince1970;
    [_tableView reloadData];
}

@end
