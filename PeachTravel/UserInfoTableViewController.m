//
//  UserInfoTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/14.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "UserInfoTableViewController.h"
#import "UserHeaderTableViewCell.h"
#import "ChangePasswordViewController.h"
#import "AccountManager.h"
#import "UserOtherTableViewCell.h"
#import "ChangeUserInfoViewController.h"
#import "VerifyCaptchaViewController.h"
#import <QiniuSDK.h>
#import "JGProgressHUDPieIndicatorView.h"
#import "JGProgressHUDSuccessIndicatorView.h"

#define userInfoHeaderCell          @"headerCell"
#define otherUserInfoCell           @"otherCell"

#define dataSource                  @[@[@"头像", @"昵称", @"ID"],  @[@"性别", @"旅行签名"], @[@"修改密码", @"手机绑定"]]

@interface UserInfoTableViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) AccountManager *accountManager;

@property (nonatomic, strong) UIActionSheet *avatarAS;
@property (nonatomic, strong) UIActionSheet *genderAS;

@property (nonatomic, strong) JGProgressHUD *HUD;

@end

@implementation UserInfoTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"个人信息";
    [self.tableView setContentInset:UIEdgeInsetsMake(10.0, 0, 0, 0)];
    self.tableView.tableFooterView = self.footerView;
    [self.tableView registerNib:[UINib nibWithNibName:@"UserHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:userInfoHeaderCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserOtherTableViewCell" bundle:nil] forCellReuseIdentifier:otherUserInfoCell];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:updateUserInfoNoti object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter & getter

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 55.0)];
        
        UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(12.0, 20.0, self.view.bounds.size.width - 24.0, 35.0)];
        logoutBtn.center = _footerView.center;
        [logoutBtn setBackgroundImage:[UIImage imageNamed:@"theme_btn_normal.png"] forState:UIControlStateNormal];
        logoutBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [logoutBtn setBackgroundImage:[UIImage imageNamed:@"theme_btn_highlight.png"] forState:UIControlStateHighlighted];
        [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        logoutBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        logoutBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [logoutBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:logoutBtn];
    }
    return _footerView;
}

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

#pragma mark - Private Methods

- (void)presentImagePicker
{
    _avatarAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册中选择", nil];
    [_avatarAS showInView:self.view];
}

/**
 *  处理各种会改变用户信息的通知
 */
- (void)userAccountHasChage
{
    [self.tableView reloadData];
}

/**
 *  获取上传青牛服务器所需要的 token，key
 *
 *  @param image
 */
- (void)uploadPhotoImage:(UIImage *)image
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [SVProgressHUD show];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];

    
    [manager GET:API_POST_PHOTOIMAGE parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self uploadPhotoToQINIUServer:image withToken:[[responseObject objectForKey:@"result"] objectForKey:@"uploadToken"] andKey:[[responseObject objectForKey:@"result"] objectForKey:@"key"]];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"修改失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"修改失败"];
    }];
    
}

/**
 *  将头像上传至七牛服务器
 *
 *  @param image       上传的图片
 *  @param uploadToken 上传的 token
 *  @param key         上传的 key
 */
- (void)uploadPhotoToQINIUServer:(UIImage *)image withToken:(NSString *)uploadToken andKey:(NSString *)key
 {
     [SVProgressHUD dismiss];
     NSData *data = UIImageJPEGRepresentation(image, 1.0);
     QNUploadManager *upManager = [[QNUploadManager alloc] init];
    
     [self.HUD showInView:self.view animated:YES];
     
     typedef void (^QNUpProgressHandler)(NSString *key, float percent);
     
     QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:@"text/plain"
                                                progressHandler:^(NSString *key, float percent) {[self incrementWithProgress:percent];}
                                                         params:@{ @"x:foo":@"fooval" }
                                                       checkCrc:YES
                                             cancellationSignal:nil];
     
     [upManager putData:data key:key token:uploadToken
               complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                   [self.accountManager updateUserInfo:[resp objectForKey:@"url"] withChangeType:ChangeAvatar];
                   [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
                   NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
                   UserHeaderTableViewCell *cell = (UserHeaderTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
                   [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:self.accountManager.account.avatar] placeholderImage:nil];

               } option:opt];
}

- (JGProgressHUD *)HUD {
    
    if (!_HUD) {
        _HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        _HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] initWithHUDStyle:JGProgressHUDStyleDark];
        
        _HUD.detailTextLabel.text = @"0% Complete";
        
        _HUD.textLabel.text = @"正在上传...";
        _HUD.layoutChangeAnimationDuration = 0.0;
    }
    return _HUD;
}

- (void)incrementWithProgress:(float)progress {
    
    NSLog(@"%f", progress);
    [self.HUD setProgress:progress animated:NO];
    _HUD.detailTextLabel.text = [NSString stringWithFormat:@"%d%% Complete", (int)(progress*100)];
    
    if (progress == 1.0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _HUD.textLabel.text = @"Success";
            _HUD.detailTextLabel.text = nil;
            
            _HUD.layoutChangeAnimationDuration = 0.3;
            _HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_HUD dismiss];
            _HUD = nil;
        });
    }
}


/**
 *  更改用户性别信息
 *
 *  @param gender 用户性别信息
 */
- (void)updateUserGender:(NSString *)gender
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [SVProgressHUD show];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:gender forKey:@"gender"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", API_USERINFO, accountManager.account.userId];
    
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:1];
            UserOtherTableViewCell *cell = (UserOtherTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
            if ([gender isEqualToString:@"F"]) {
                cell.cellDetail.text = @"美女";
            }
            if ([gender isEqualToString:@"M"]) {
                cell.cellDetail.text = @"帅锅";
            }
            if ([gender isEqualToString:@"U"]) {
                cell.cellDetail.text = @"不告诉你";
            }
            [accountManager updateUserInfo:gender withChangeType:ChangeGender];
            [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
        } else {
            [SVProgressHUD showErrorWithStatus:@"修改失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"修改失败"];
    }];
}

#pragma mark - IBAction Methods

/**
 *  退出登录
 *
 *  @param sender
 */
-(IBAction)logout:(id)sender
{
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:nil
                                                  message:@"确定退出已登陆账户"
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        UserHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userInfoHeaderCell forIndexPath:indexPath];
        cell.cellLabel.text = dataSource[indexPath.section][indexPath.row];
        cell.testImage.image = [UIImage imageNamed:@"ic_setting_avatar.png"];
        [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:self.accountManager.account.avatar] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.png"]];
        return cell;
    } else {
        UserOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:otherUserInfoCell forIndexPath:indexPath];
        cell.cellTitle.text = dataSource[indexPath.section][indexPath.row];
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_nick.png"];
                cell.cellDetail.text = self.accountManager.account.nickName;
            } else if (indexPath.row == 2) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_nick.png"];
                cell.cellDetail.text = [NSString stringWithFormat:@"%d", [self.accountManager.account.userId intValue]];
            }
        } else if (indexPath.section ==  1) {
            if (indexPath.row == 0) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_nick.png"];
                if ([self.accountManager.account.gender isEqualToString:@"F"]) {
                    cell.cellDetail.text = @"美女";
                }
                if ([self.accountManager.account.gender isEqualToString:@"M"]) {
                    cell.cellDetail.text = @"帅锅";
                }
                if ([self.accountManager.account.gender isEqualToString:@"U"]) {
                    cell.cellDetail.text = @"不告诉你";
                }

            } else if (indexPath.row == 1) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_memo.png"];
                cell.cellDetail.text = self.accountManager.account.signature;
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_password.png"];
            } else if (indexPath.row == 1) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_bindphone.png"];
                NSString *tel = self.accountManager.account.tel;
                if (tel == nil || tel.length < 1) {
                    cell.cellDetail.text = @"未绑定";
                } else {
                    cell.cellDetail.text = tel;
                }
            }
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self presentImagePicker];
        } else if (indexPath.row == 1) {
            ChangeUserInfoViewController *changeUserInfo = [[ChangeUserInfoViewController alloc] init];
            changeUserInfo.changeType = ChangeName;
            [self.navigationController pushViewController:changeUserInfo animated:YES];
            changeUserInfo.content = self.accountManager.account.nickName;
        }
        
    } else if (indexPath.section ==  1) {
        if (indexPath.row == 0) {
            _genderAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"美女", @"帅锅", @"不告诉你", nil];
            [_genderAS showInView:self.view];
            
        } else if (indexPath.row == 1) {
            ChangeUserInfoViewController *changeUserInfo = [[ChangeUserInfoViewController alloc] init];
            changeUserInfo.changeType = ChangeSignature;
            [self.navigationController pushViewController:changeUserInfo animated:YES];
            changeUserInfo.content = self.accountManager.account.signature;
        }
        
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            ChangePasswordViewController *changePasswordCtl = [[ChangePasswordViewController alloc] init];
            [self.navigationController pushViewController:changePasswordCtl animated:YES];
        } else if (indexPath.row == 1) {
            VerifyCaptchaViewController *changePasswordCtl = [[VerifyCaptchaViewController alloc] init];
            changePasswordCtl.verifyCaptchaType = UserBindTel;
            [self.navigationController pushViewController:changePasswordCtl animated:YES];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _avatarAS) {
        UIImagePickerControllerSourceType sourceType;
        if (buttonIndex == 0) {
            sourceType  = UIImagePickerControllerSourceTypeCamera;
        } else if (buttonIndex == 1) {
            sourceType  = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            return;
        }
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
        
    } else if (actionSheet == _genderAS) {          //相应切换性别的
        NSString *gender;
        if (buttonIndex == 0) {
            gender = @"F";
        }
        if (buttonIndex == 1) {
            gender = @"M";
        }
        if (buttonIndex == 2) {
            gender = @"U";
        }
        if (buttonIndex == 3) {   //点击取消
            return;
        }

        [self updateUserGender:gender];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
   
    UIImage *headerImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self uploadPhotoImage:headerImage];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [accountManager logout];
        [[NSNotificationCenter defaultCenter] postNotificationName:userDidLogoutNoti object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end



