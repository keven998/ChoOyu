//
//  EditUserSignatureViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "EditUserSignatureViewController.h"

@interface EditUserSignatureViewController ()

@property (nonatomic, strong) UITextView *contentEditor;

@end

@implementation EditUserSignatureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = @"修改签名";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveEdit:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCtl)];

    
    CGFloat width = self.view.frame.size.width;
    
    UIView *eborder = [[UIView alloc] initWithFrame:CGRectMake(5, 20+64, width - 10, 86.0)];
    eborder.backgroundColor = [UIColor whiteColor];
    eborder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    eborder.layer.borderColor = COLOR_LINE.CGColor;
    eborder.layer.borderWidth = 1.0;
    eborder.layer.cornerRadius = 3.0;
    [self.view addSubview:eborder];
    
    UITextView *suggestion = [[UITextView alloc] initWithFrame:CGRectMake(5.0, 4, width - 10.0, 78.0)];
    suggestion.backgroundColor = [UIColor clearColor];
    suggestion.textColor = COLOR_TEXT_I;
    suggestion.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    suggestion.font = [UIFont systemFontOfSize:14.0];
    suggestion.scrollEnabled = YES;
    [eborder addSubview:suggestion];
    _contentEditor = suggestion;
    _contentEditor.text = [AccountManager shareAccountManager].account.signature;
}

- (void)showkeyboard
{
    [_contentEditor becomeFirstResponder];
}

- (void)goBack
{
    [_contentEditor resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (IBAction)saveEdit:(id)sender
{
    [_contentEditor resignFirstResponder];
    [[AccountManager shareAccountManager] asyncChangeSignature:_contentEditor.text completion:^(BOOL isSuccess, UserInfoInputError error, NSString *errStr) {
        if (isSuccess) {
            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
        } else if (errStr){
            [SVProgressHUD showHint:errStr];
        } else {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)dismissCtl
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
