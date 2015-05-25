//
//  SignatureViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/5/14.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "SignatureViewController.h"

@interface SignatureViewController ()<UITextViewDelegate>

{
    UITextView *_contentTextField;
}

@end

@implementation SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _navTitle;
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"保存 " style:UIBarButtonItemStylePlain target:self action:@selector(saveChange:)];
    rightBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = rightBtn;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@" 取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    _contentTextField = [[UITextView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 88)];
    _contentTextField.layer.borderColor = UIColorFromRGB(0xdcdcdc).CGColor;
    _contentTextField.layer.borderWidth = 0.5;
    _contentTextField.delegate = self;
    UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0, 20.0)];
    sv.backgroundColor = [UIColor whiteColor];

    [_contentTextField becomeFirstResponder];
    _contentTextField.font = [UIFont systemFontOfSize:14.0];
    _contentTextField.text = _content;
    [self.view addSubview:_contentTextField];
    

}
-(void)dismissKeyBoard
{
    [_contentTextField resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView;
{
    self.navigationItem.rightBarButtonItem.enabled = ![textView.text isEqualToString:_content];
    if (!_acceptEmptyContent) {
        NSString *str = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (str == nil || str.length == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
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
    if (_saveEdition != nil) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.title = @"正在提交...";
        self.saveEdition(_contentTextField.text, ^(BOOL completed) {
            if (completed) {
                [self goBack];
            } else {
                self.navigationItem.title = _navTitle;
                self.navigationItem.leftBarButtonItem.enabled = YES;
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
