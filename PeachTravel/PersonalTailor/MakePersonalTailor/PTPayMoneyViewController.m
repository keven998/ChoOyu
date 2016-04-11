//
//  PTPayMoneyViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/6/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTPayMoneyViewController.h"

@interface PTPayMoneyViewController ()
@property (weak, nonatomic) IBOutlet UILabel *noMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIView *inputMoneyView;
@property (weak, nonatomic) IBOutlet UITextField *inputMoneyTextfield;
@property (weak, nonatomic) IBOutlet UIButton *commitPTButton;

@end

@implementation PTPayMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _noMoneyLabel.layer.borderColor = COLOR_LINE.CGColor;
    _noMoneyLabel.layer.borderWidth = 0.5;
    _moneyLabel.layer.borderColor = COLOR_LINE.CGColor;
    _moneyLabel.layer.borderWidth = 0.5;
    _inputMoneyView.layer.borderColor = COLOR_LINE.CGColor;
    _inputMoneyView.layer.borderWidth = 0.5;
    
    [_commitPTButton setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_PRICE_RED] forState:UIControlStateNormal];
    _commitPTButton.layer.cornerRadius = 5.0;
    _commitPTButton.clipsToBounds = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showAboutMoney:(id)sender {
    
}

@end
