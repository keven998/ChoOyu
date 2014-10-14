//
//  UserInfoTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/14.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "UserInfoTableViewController.h"
#import "UserHeaderTableViewCell.h"

#define userInfoHeaderCell          @"headerCell"
#define otherUserInfoCell           @"otherCell"

#define dataSource                  @[@[@"头像", @"ID", @"昵称", @"性别", @"个性签名"], @[@"修改密码", @"手机绑定"]]

@interface UserInfoTableViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation UserInfoTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"个人信息";
    [self.tableView setContentInset:UIEdgeInsetsMake(-35, 0, 0, 0)];

    [self.tableView registerNib:[UINib nibWithNibName:@"UserHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:userInfoHeaderCell];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:otherUserInfoCell];
}

#pragma mark - Private Methods
- (void)presentImagePicker
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册中选择", nil];
    [actionSheet showInView:self.view];
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
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:otherUserInfoCell forIndexPath:indexPath];
        cell.textLabel.text = dataSource[indexPath.section][indexPath.row];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self presentImagePicker];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    UserHeaderTableViewCell *cell = (UserHeaderTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
    cell.testImage.image = [info objectForKey:UIImagePickerControllerEditedImage];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType;
    if (buttonIndex == 0) {
        sourceType  = UIImagePickerControllerSourceTypeCamera;
    } else {
        sourceType  = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

@end



