//
//  PTPayMoneyViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/6/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTPayMoneyViewController.h"
#import "DownSheet.h"
#import "TZPayManager.h"
#import "PersonalTailorManager.h"

@interface PTPayMoneyViewController () <UITextFieldDelegate, DownSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *noMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIView *inputMoneyView;
@property (weak, nonatomic) IBOutlet UITextField *inputMoneyTextfield;
@property (weak, nonatomic) IBOutlet UIButton *commitPTButton;
@property (weak, nonatomic) IBOutlet UIButton *freeSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *paySelectButton;
@property (strong, nonatomic) DownSheet *payDownSheet;
@property (strong, nonatomic) TZPayManager *payManager;

@end

@implementation PTPayMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"私人定制";
    _noMoneyLabel.layer.borderColor = COLOR_LINE.CGColor;
    _noMoneyLabel.layer.borderWidth = 0.5;
    _moneyLabel.layer.borderColor = COLOR_LINE.CGColor;
    _moneyLabel.layer.borderWidth = 0.5;
    _inputMoneyView.layer.borderColor = COLOR_LINE.CGColor;
    _inputMoneyView.layer.borderWidth = 0.5;
    
    [_commitPTButton setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_PRICE_RED] forState:UIControlStateNormal];
    _commitPTButton.layer.cornerRadius = 5.0;
    _commitPTButton.clipsToBounds = YES;
    _inputMoneyTextfield.delegate = self;
    [_freeSelectButton sendActionsForControlEvents:UIControlEventTouchUpInside];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)commintOrderAction:(id)sender {
    if (_freeSelectButton.selected) {
        [PersonalTailorManager asyncMakePersonalTailorWithPTModel:_ptDetailModel completionBlock:^(BOOL isSuccess, PTDetailModel *ptDetailModel) {
            if (isSuccess) {
                _ptDetailModel = ptDetailModel;
            } else {
                [SVProgressHUD showHint:@"需求发布失败"];
            }
        }];
        
    } else {
        DownSheetModel *modelOne = [[DownSheetModel alloc] init];
        modelOne.title = @"支付宝";
        modelOne.icon= @"icon_pay_alipay";
        
        DownSheetModel *modelTwo = [[DownSheetModel alloc] init];
        modelTwo.title = @"微信";
        modelTwo.icon = @"icon_pay_wechat";
        
        _payDownSheet = [[DownSheet alloc] initWithlist:@[modelOne, modelTwo] height:40 andTitle:@"选择支付方式"];
        _payDownSheet.delegate = self;
        [_payDownSheet showInView:self];
    }
}

#pragma mark - DownSheetDelegate

- (void)didSelectIndex:(NSInteger)index
{
    _payManager = [[TZPayManager alloc] init];
    TZPayPlatform platform;
    if (index == 0) {
        platform = kAlipay;
    } else {
        platform = kWeichatPay;
    }
    
    [MobClick event:@"event_payForOrder"];
}

- (void)shouldDismissSheet
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"取消支付定金,发布的需求将失效,确认取消支付?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [_payDownSheet dismissSheet];
            
        }
    }];
}

- (IBAction)freeSelectButtonAction:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected = !sender.selected;
    _paySelectButton.selected = NO;
    _inputMoneyView.hidden = YES;
    [_inputMoneyTextfield resignFirstResponder];
}

- (IBAction)paySelectButtonAction:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected = !sender.selected;
    _freeSelectButton.selected = NO;
    _inputMoneyView.hidden = NO;
}

- (IBAction)showAboutMoney:(id)sender {
    UIView *aboutMoneyBg = [[UIView alloc] initWithFrame:self.view.bounds];
    aboutMoneyBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, kWindowWidth-40, kWindowHeight-200)];
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.font = [UIFont systemFontOfSize:15.0];
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.text = @"悬赏金说明";
    [aboutMoneyBg addSubview:contentLabel];
    
    UIButton *aboutMoneyButton = [[UIButton alloc] initWithFrame:CGRectMake((kWindowWidth-100)/2, kWindowHeight-100, 100, 100)];
    [aboutMoneyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [aboutMoneyButton setTitle:@"关闭" forState:UIControlStateNormal];
    [aboutMoneyButton addTarget:self action:@selector(closeAboutMoney:) forControlEvents:UIControlEventTouchUpInside];
    [aboutMoneyBg addSubview:aboutMoneyButton];
    [self.navigationController.view addSubview:aboutMoneyBg];
}

- (void)closeAboutMoney:(UIButton *)sender
{
    [sender.superview removeFromSuperview];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [_inputMoneyTextfield resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
