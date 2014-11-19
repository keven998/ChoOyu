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

#define userInfoHeaderCell          @"headerCell"
#define otherUserInfoCell           @"otherCell"

#define dataSource                  @[@[@"头像", @"ID", @"昵称", @"性别", @"个性签名"], @[@"修改密码", @"手机绑定"]]

@interface UserInfoTableViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) AccountManager *accountManager;

@end

@implementation UserInfoTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"个人信息";
    [self.tableView setContentInset:UIEdgeInsetsMake(-35, 0, 0, 0)];
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
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 80)];
        
        UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, _footerView.frame.size.width - 20.0, 35.0)];
        logoutBtn.center = _footerView.center;
        logoutBtn.backgroundColor = UIColorFromRGB(0xee528c);
        [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        logoutBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册中选择", nil];
    [actionSheet showInView:self.view];
}

- (void)userAccountHasChage
{
    [self.tableView reloadData];
}

#pragma mark - IBAction Methods

-(IBAction)logout:(id)sender
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [accountManager logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:userDidLogoutNoti object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        UserHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userInfoHeaderCell forIndexPath:indexPath];
        cell.cellLabel.text = dataSource[indexPath.section][indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:self.accountManager.account.avatar] placeholderImage:nil];
        return cell;
    } else {
        UserOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:otherUserInfoCell forIndexPath:indexPath];
        cell.cellTitle.text = dataSource[indexPath.section][indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.section == 0 && indexPath.row == 1) {
            cell.cellDetail.text = [NSString stringWithFormat:@"ID%d", [self.accountManager.account.userId intValue]];
        } else if (indexPath.section == 0 && indexPath.row == 2) {
            cell.cellDetail.text = self.accountManager.account.nickName;
        } else if (indexPath.section == 0 && indexPath.row == 4) {
            cell.cellDetail.text = self.accountManager.account.signature.length>0 ? self.accountManager.account.signature:@"修改";
        }
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self presentImagePicker];
    }
    if (indexPath.section == 0 && indexPath.row == 2) {
        ChangeUserInfoViewController *changeUserInfo = [[ChangeUserInfoViewController alloc] init];
        changeUserInfo.changeType = ChangeName;
        [self.navigationController pushViewController:changeUserInfo animated:YES];
        changeUserInfo.content = self.accountManager.account.nickName;
    }
    if (indexPath.section == 0 && indexPath.row == 4) {
        ChangeUserInfoViewController *changeUserInfo = [[ChangeUserInfoViewController alloc] init];
        changeUserInfo.changeType = ChangeSignature;
        [self.navigationController pushViewController:changeUserInfo animated:YES];
        changeUserInfo.content = self.accountManager.account.signature;
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        ChangePasswordViewController *changePasswordCtl = [[ChangePasswordViewController alloc] init];
        [self.navigationController pushViewController:changePasswordCtl animated:YES];
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
        VerifyCaptchaViewController *changePasswordCtl = [[VerifyCaptchaViewController alloc] init];
        changePasswordCtl.verifyCaptchaType = UserBindTel;
        [self.navigationController pushViewController:changePasswordCtl animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType;
    if (buttonIndex == 0) {
        sourceType  = UIImagePickerControllerSourceTypeCamera;
    } else if (buttonIndex == 1){
        sourceType  = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        return;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    UserHeaderTableViewCell *cell = (UserHeaderTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
    UIImage *headerImage = [info objectForKey:UIImagePickerControllerEditedImage];
    cell.userPhoto.image = headerImage;
}


@end



