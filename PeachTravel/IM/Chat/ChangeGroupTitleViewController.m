//
//  ChangeGroupTitleViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/5.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChangeGroupTitleViewController.h"
#import "PeachTravel-swift.h"

@interface ChangeGroupTitleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleLable;

@end

@implementation ChangeGroupTitleViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleLable.text = _oldTitle;
    self.navigationItem.title = @"修改群名称";
    
    UIBarButtonItem * addBtn = [[UIBarButtonItem alloc]initWithTitle:@"确定 " style:UIBarButtonItemStylePlain target:self action:@selector(confirm:)];
    addBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = addBtn;
    
    _titleLable.layer.borderColor = UIColorFromRGB(0xdcdcdc).CGColor;
    _titleLable.layer.borderWidth = 0.5;
    UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0, 20.0)];
    sv.backgroundColor = [UIColor whiteColor];
    _titleLable.leftView = sv;
    _titleLable.leftViewMode = UITextFieldViewModeAlways;
    [_titleLable becomeFirstResponder];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - action methods

- (void)goBack
{
    [self.delegate changeGroupTitle];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirm:(id)sender
{
    TZProgressHUD *hud;
    [_titleLable resignFirstResponder];
    NSString *title = [_titleLable.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (title.length == 0) {
        [SVProgressHUD showHint:@"群标题不能为空"];
    } else {
        __weak typeof(ChangeGroupTitleViewController *)weakSelf = self;
        hud = [[TZProgressHUD alloc] init];
        [hud showHUDInViewController:weakSelf content:64];
        IMDiscussionGroupManager *manager = [IMDiscussionGroupManager shareInstance];
        [manager asyncChangeDiscussionGroupTitleWithGroup:_group title:title completion:^(BOOL isSuccess, NSInteger errorCode) {
            [hud hideTZHUD];
            if (isSuccess) {
                [SVProgressHUD showHint:@"修改成功"];
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:updateChateGroupTitleNoti object:title];
                IMClientManager *client = [IMClientManager shareInstance];
                [client.conversationManager updateConversationName:title chatterId:_group.groupId];
                [self performSelector:@selector(goBack) withObject:nil afterDelay:0.4];
            }
        }];
    }
    
  
}

@end
