//
//  EditUserAlbumDescViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "EditUserAlbumDescViewController.h"

@interface EditUserAlbumDescViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;

@end

@implementation EditUserAlbumDescViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"编辑文字描述";
    self.view.backgroundColor = APP_PAGE_COLOR;
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveChange) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_albumImage.smallImageUrl]];
    _descTextView.text = _albumImage.imageDesc;
    [_descTextView becomeFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissCtl
{
    if ([_descTextView.text isEqualToString:_albumImage.imageDesc]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定放弃编辑？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (void)saveChange
{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
