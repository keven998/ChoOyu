//
//  EditUserAlbumDescViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "EditUserAlbumDescViewController.h"
#import "UserAlbumManager.h"

@interface EditUserAlbumDescViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (nonatomic, strong) UIButton *saveBtn;

@end

@implementation EditUserAlbumDescViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"编辑文字描述";
    self.view.backgroundColor = APP_PAGE_COLOR;
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    _saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveBtn setTitleColor:COLOR_TEXT_III forState:UIControlStateDisabled];
    [_saveBtn addTarget:self action:@selector(saveChange) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_saveBtn];
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_albumImage.smallImageUrl]];
    _descTextView.delegate = self;
    _descTextView.text = _albumImage.imageDesc;
    [_descTextView becomeFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)goBack
{
    if ([_descTextView.text isEqualToString:_albumImage.imageDesc]) {
        [self dismissCtl];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定放弃编辑？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self dismissCtl];
            }
        }];
    }
}

- (void)dismissCtl
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)saveChange
{
    if ([_albumImage.imageDesc isEqualToString:_descTextView.text]) {
        [self dismissCtl];
        return;
    }
    [UserAlbumManager asyncUpdateUserAlbumCaption:_descTextView.text withImageId:_albumImage.imageId completion:^(BOOL isSuccess) {
        if (isSuccess) {
            _albumImage.imageDesc = _descTextView.text;
            [SVProgressHUD showHint:@"修改成功"];
            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.5];
        } else {
            [SVProgressHUD showHint:@"修改失败"];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isBlankString]) {
        _saveBtn.enabled = NO;
    } else {
        _saveBtn.enabled = YES;
    }
}

@end
