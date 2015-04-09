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
#import "FootPrintViewController.h"
#import "CityListTableViewController.h"
#import "SelectionTableViewController.h"

#define accountDetailHeaderCell          @"headerCell"
#define otherUserInfoCell           @"otherCell"

#define cellDataSource              @[@[@"头像", @"名字", @"状态"], @[@"手机绑定", @"修改密码"], @[@"旅行足迹"], @[@"签名"], @[@"性别", @"生日", @"现居地"]]

@interface UserInfoTableViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, SelectDelegate>

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) AccountManager *accountManager;

@property (nonatomic, strong) UIActionSheet *avatarAS;

@property (nonatomic, strong) JGProgressHUD *HUD;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *datePickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation UserInfoTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.navigationController.navigationBarHidden) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 63.0)];
        bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:@"个人信息"];
        navTitle.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
        [bar pushNavigationItem:navTitle animated:YES];
        bar.shadowImage = [ConvertMethods createImageWithColor:APP_THEME_COLOR];
        [self.view addSubview:bar];
    } else {
        self.navigationItem.title = @"个人信息";
    }
    
    [self loadUserInfo];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:accountDetailHeaderCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserOtherTableViewCell" bundle:nil] forCellReuseIdentifier:otherUserInfoCell];
    self.tableView.tableFooterView = self.footerView;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:updateUserInfoNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBack) name:userDidLogoutNoti object:nil];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_personal_profile"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_personal_profile"];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
        logoutBtn.layer.cornerRadius = 4.0;
        logoutBtn.clipsToBounds = YES;
        [logoutBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
        logoutBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        logoutBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        logoutBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [logoutBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:logoutBtn];
    }
    return _footerView;
}

- (UIView *)datePickerView
{
    if (!_datePickerView) {
        _datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 220)];
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 180)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.maximumDate = [NSDate date];
        [_datePickerView addSubview:_datePicker];
        NSDate *birthday = [ConvertMethods stringToDate:self.accountManager.accountDetail.birthday withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
        if (birthday) {
            _datePicker.date = birthday;
        }
        _datePickerView.backgroundColor = [UIColor whiteColor];
        
        UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _datePickerView.bounds.size.width, 40)];
        confirmBtn.backgroundColor = APP_PAGE_COLOR;
        confirmBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:APP_SUB_THEME_COLOR forState:UIControlStateNormal];
        [_datePickerView addSubview:confirmBtn];
        [confirmBtn addTarget:self action:@selector(confirmDatePick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _datePickerView;
}

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

#pragma mark - Private Methods

- (void)loadUserInfo
{
    [self.accountManager.accountDetail loadUserInfoFromServer:^(bool isSuccess) {
        if (isSuccess) {
            [self.tableView reloadData];
        }
    }];
}

- (void)presentImagePicker
{
    _avatarAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册中选择", nil];
    [_avatarAS showInView:self.view];
}

/**
 *  显示选择日期选择器
 */
- (void)showDatePicker
{
    UIView *bkgView = [[UIView alloc] initWithFrame:self.view.bounds];
    bkgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDatePicker)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [bkgView addGestureRecognizer:tapGesture];
    
    [self.navigationController.view addSubview:bkgView];
    [bkgView addSubview:self.datePickerView];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.datePickerView setFrame:CGRectMake(0, self.view.bounds.size.height-220, self.view.bounds.size.width, 220)];

    } completion:^(BOOL finished) {
        
    }];
}

/**
 *  隐藏日期选择器
 */
- (void)hideDatePicker
{
    [_datePickerView.superview removeFromSuperview];
    _datePickerView = nil;
}

/**
 *  确定日期选择
 *
 *  @param sender
 */
- (void)confirmDatePick:(id)sender
{
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInView:self.view];

    NSString *dataStr = [ConvertMethods dateToString:_datePicker.date withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
    [self.accountManager asyncChangeBirthday:dataStr completion:^(BOOL isSuccess, NSString *errStr) {
        [hud hideTZHUD];
        [self hideDatePicker];
    }];
}

/**
 *  处理各种会改变用户信息的通知
 */
- (void)userAccountHasChage
{
    [self.tableView reloadData];
}

/**
 *  获取上传七牛服务器所需要的 token，key
 *
 *  @param image
 */
- (void)uploadPhotoImage:(UIImage *)image
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
     __weak typeof(UserInfoTableViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", self.accountManager.account.userId] forHTTPHeaderField:@"UserId"];

    [manager GET:API_POST_PHOTOIMAGE parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self uploadPhotoToQINIUServer:image withToken:[[responseObject objectForKey:@"result"] objectForKey:@"uploadToken"] andKey:[[responseObject objectForKey:@"result"] objectForKey:@"key"]];
              
        } else {
             if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
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
                   [self.accountManager updateUserInfo:[resp objectForKey:@"urlSmall"] withChangeType:ChangeSmallAvatar];

                   [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
                   NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
                   UserHeaderTableViewCell *cell = (UserHeaderTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
                   [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:self.self.accountManager.accountDetail.basicUserInfo.avatarSmall] placeholderImage:nil];

               } option:opt];
}

- (JGProgressHUD *)HUD {
    if (!_HUD) {
        _HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        _HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] initWithHUDStyle:JGProgressHUDStyleDark];
        
        _HUD.detailTextLabel.text = nil;
        
        _HUD.textLabel.text = @"正在上传";
        _HUD.layoutChangeAnimationDuration = 0.0;
    }
    return _HUD;
}

- (void)incrementWithProgress:(float)progress {
    _HUD.textLabel.text = [NSString stringWithFormat:@"%d%%", (int)(progress*100)];
    [self.HUD setProgress:progress animated:YES];
    
    if (progress == 1.0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_HUD dismiss];
            _HUD = nil;
            [SVProgressHUD showHint:@"修改成功"];
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
    if ([gender isEqualToString:accountManager.account.gender]) {
        return;
    }
    __weak typeof(UserInfoTableViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [accountManager asyncChangeGender:gender completion:^(BOOL isSuccess, NSString *errStr) {
        [hud hideTZHUD];
        if (isSuccess) {
            NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:1];
            [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
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
    if (section == 0) {
        return 0;
    }
    return 10.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return cellDataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cellDataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        UserHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:accountDetailHeaderCell forIndexPath:indexPath];
        cell.cellLabel.text = cellDataSource[indexPath.section][indexPath.row];
        cell.testImage.image = [UIImage imageNamed:@"ic_setting_avatar.png"];
        [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:self.self.accountManager.accountDetail.basicUserInfo.avatarSmall] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.png"]];
        return cell;
    } else {
        UserOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:otherUserInfoCell forIndexPath:indexPath];
        cell.cellTitle.text = cellDataSource[indexPath.section][indexPath.row];
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_nick.png"];
                cell.cellDetail.text = self.self.accountManager.accountDetail.basicUserInfo.nickName;
            } else if (indexPath.row == 2) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_nick.png"];
                cell.cellDetail.text = [NSString stringWithFormat:@"%d", [self.self.accountManager.accountDetail.basicUserInfo.userId intValue]];
            }
        } else if (indexPath.section ==  1) {
            if (indexPath.row == 0) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_gender.png"];
                if ([self.self.accountManager.accountDetail.basicUserInfo.gender isEqualToString:@"F"]) {
                    cell.cellDetail.text = @"美女";
                }
                if ([self.self.accountManager.accountDetail.basicUserInfo.gender isEqualToString:@"M"]) {
                    cell.cellDetail.text = @"帅锅";
                }
                if ([self.self.accountManager.accountDetail.basicUserInfo.gender isEqualToString:@"U"]) {
                    cell.cellDetail.text = @"不告诉你";
                }

            } else if (indexPath.row == 1) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_memo.png"];
                cell.cellDetail.text = self.self.accountManager.accountDetail.basicUserInfo.signature;
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_password.png"];
            } else if (indexPath.row == 0) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_bindphone.png"];
                NSString *tel = self.self.accountManager.accountDetail.basicUserInfo.tel;
                if (tel == nil || tel.length < 1) {
                    cell.cellDetail.text = @"未绑定";
                } else {
                    cell.cellDetail.text = tel;
                }
            }
        } else if (indexPath.section == 4) {
            if (indexPath.row == 1) {
                cell.cellDetail.text = self.accountManager.accountDetail.birthday;
            } else if (indexPath.row == 2) {
                cell.cellDetail.text = self.accountManager.accountDetail.residence;
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
            [MobClick event:@"event_update_avatar"];
        } else if (indexPath.row == 1) {
            [MobClick event:@"event_update_nick"];
            ChangeUserInfoViewController *changeUserInfo = [[ChangeUserInfoViewController alloc] init];
            changeUserInfo.changeType = ChangeName;
            changeUserInfo.navTitle = @"修改名字";
            TZNavigationViewController *navc = [[TZNavigationViewController alloc] initWithRootViewController:changeUserInfo];
            [self presentViewController:navc animated:YES completion:^ {
                changeUserInfo.content = self.accountManager.accountDetail.basicUserInfo.nickName;
            }];
        } else if (indexPath.row == 2) {
            [self showHint:@"猥琐攻城师不让修改这个～"];
        }
        
    } else if (indexPath.section ==  1) {
        if (indexPath.row == 0) {
            [MobClick event:@"event_update_gender"];
            SelectionTableViewController *ctl = [[SelectionTableViewController alloc] init];
            ctl.contentItems = @[@"美女", @"帅锅", @"一言难尽", @"保密"];
            ctl.titleTxt = @"我是";
            ctl.delegate = self;
            ctl.selectItem = self.navigationItem.rightBarButtonItem.title;
            TZNavigationViewController *nav = [[TZNavigationViewController alloc] initWithRootViewController:ctl];
            [self presentViewController:nav animated:YES completion:nil];
        } else if (indexPath.row == 1) {
            [MobClick event:@"event_update_memo"];
            
            ChangeUserInfoViewController *changeUserInfo = [[ChangeUserInfoViewController alloc] init];
            changeUserInfo.changeType = ChangeSignature;
            changeUserInfo.navTitle = @"个性签名";
            TZNavigationViewController *navc = [[TZNavigationViewController alloc] initWithRootViewController:changeUserInfo];
            [self presentViewController:navc animated:YES completion:^ {
                changeUserInfo.content = self.accountManager.accountDetail.basicUserInfo.signature;
            }];
        }
        
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [MobClick event:@"event_update_password"];

            ChangePasswordViewController *changePasswordCtl = [[ChangePasswordViewController alloc] init];
//            [self.navigationController pushViewController:changePasswordCtl animated:YES];
            [self presentViewController:changePasswordCtl animated:YES completion:nil];
        } else if (indexPath.row == 1) {
            [MobClick event:@"event_update_phone"];

            VerifyCaptchaViewController *changePasswordCtl = [[VerifyCaptchaViewController alloc] init];
            changePasswordCtl.verifyCaptchaType = UserBindTel;
//            [self.navigationController pushViewController:changePasswordCtl animated:YES];
            [self.navigationController presentViewController:[[TZNavigationViewController alloc] initWithRootViewController:changePasswordCtl] animated:YES completion:nil];
        }
    } else if (indexPath.section == 3) {
        FootPrintViewController *footCtl = [[FootPrintViewController alloc] init];
        [self presentViewController:footCtl animated:YES completion:nil];
    } else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            [self showDatePicker];
        } else if (indexPath.row == 2) {
            NSString *url = [[NSBundle mainBundle] pathForResource:@"DomesticCityDataSource" ofType:@"plist"];
            NSArray *cityArray = [NSArray arrayWithContentsOfFile:url];
            CityListTableViewController *cityListCtl = [[CityListTableViewController alloc] init];
            cityListCtl.cityDataSource = cityArray;
            cityListCtl.needUserLocation = YES;
//            [self.navigationController pushViewController:cityListCtl animated:YES];
            TZNavigationViewController *navc = [[TZNavigationViewController alloc] initWithRootViewController:cityListCtl];
            [self presentViewController:navc animated:YES completion:nil];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SelectDelegate

- (void)selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath {
    
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
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    }
//    else if (actionSheet == _genderAS) {          //相应切换性别的
//        NSString *gender;
//        if (buttonIndex == 0) {
//            gender = @"F";
//        }
//        if (buttonIndex == 1) {
//            gender = @"M";
//        }
//        if (buttonIndex == 2) {
//            gender = @"U";
//        }
//        if (buttonIndex == 3) {   //点击取消
//            return;
//        }
//
//        [self updateUserGender:gender];
//    }
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
        [MobClick event:@"event_logout"];
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [SVProgressHUD show];
        [accountManager asyncLogout:^(BOOL isSuccess) {
            [self showHint:@"退出成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

@end



