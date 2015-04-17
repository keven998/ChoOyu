//
//  BaseTextSettingViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "BaseTextSettingViewController.h"
#import "AccountManager.h"

@interface BaseTextSettingViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *contentTextField;

@end

@implementation BaseTextSettingViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customNavigationItem.title = _navTitle;
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"保存 " style:UIBarButtonItemStyleBordered target:self action:@selector(saveChange:)];
    rightBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = rightBtn;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@" 取消" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    _contentTextField.layer.borderColor = UIColorFromRGB(0xdcdcdc).CGColor;
    _contentTextField.layer.borderWidth = 0.5;
    _contentTextField.delegate = self;
    UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0, 20.0)];
    sv.backgroundColor = [UIColor whiteColor];
    _contentTextField.leftView = sv;
    _contentTextField.leftViewMode = UITextFieldViewModeAlways;
    [_contentTextField becomeFirstResponder];
    _contentTextField.font = [UIFont systemFontOfSize:14.0];
    _contentTextField.text = _content;
    [_contentTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
}

/**
 *  重写父类的返回方法
 */
- (void)goBack
{
    if (self.navigationController.childViewControllers.count <= 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _contentTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void) textChanged:(UITextField *)textField {
    self.navigationItem.rightBarButtonItem.enabled = ![textField.text isEqualToString:_content];
    if (!_acceptEmptyContent) {
        NSString *str = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (str == nil || str.length == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
}

#pragma mark - IBAction Methods

- (IBAction)saveChange:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (_saveEdition != nil) {
        self.saveEdition(_contentTextField.text, ^(BOOL completed) {
            if (completed) {
                [self goBack];
            } else {
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
        });
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}



@end
