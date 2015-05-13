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
#import "VerifyCaptchaViewController.h"
#import <QiniuSDK.h>
#import "JGProgressHUDPieIndicatorView.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "FootPrintViewController.h"
#import "CityListTableViewController.h"
#import "SelectionTableViewController.h"
#import "PXAlertView+Customization.h"
#import "BaseTextSettingViewController.h"
#import "JobListViewController.h"
#import "StatusListViewController.h"
#import "HeaderCell.h"
#import "HeaderPictureCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#define accountDetailHeaderCell          @"headerCell"
#define otherUserInfoCell           @"otherCell"

#define cellDataSource              @[@[@"头像", @"名字", @"状态"], @[@"手机绑定", @"修改密码"], @[@"旅行足迹"], @[@"签名"], @[@"性别", @"生日", @"现居地",@"职业"]]

@interface UserInfoTableViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, SelectDelegate,ChangJobDelegate,ChangStatusDelegate,ShowPickerDelegate>

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) AccountManager *accountManager;

@property (nonatomic, strong) JGProgressHUD *HUD;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *datePickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, copy) NSMutableArray *footPrintArray;
@end

@implementation UserInfoTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我";
    
    [self loadUserInfo];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorColor = APP_DIVIDER_COLOR;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:accountDetailHeaderCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserOtherTableViewCell" bundle:nil] forCellReuseIdentifier:otherUserInfoCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"HeaderCell" bundle:nil] forCellReuseIdentifier:@"zuji"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HeaderPictureCell" bundle:nil] forCellReuseIdentifier:@"header"];
    self.tableView.tableFooterView = self.footerView;
    
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
    PXAlertView *alertView = [PXAlertView showAlertWithTitle:nil
                                                     message:nil
                                                 cancelTitle:@"取消"
                                                 otherTitles:@[@"拍照", @"从相册中选择"]
                                                  completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                      UIImagePickerControllerSourceType sourceType;
                                                      if (buttonIndex == 1) {
                                                          sourceType  = UIImagePickerControllerSourceTypeCamera;
                                                      } else if (buttonIndex == 2) {
                                                          sourceType  = UIImagePickerControllerSourceTypePhotoLibrary;
                                                      } else {
                                                          return;
                                                      }
                                                      UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                                      picker.delegate = self;
                                                      picker.allowsEditing = YES;
                                                      picker.sourceType = sourceType;
                                                      [self presentViewController:picker animated:YES completion:nil];
                                                  }];
    [alertView setTitleFont:[UIFont systemFontOfSize:16]];
    [alertView useDefaultIOS7Style];
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
    } completion:nil];
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
//        NSLog(@"%@", responseObject);
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
                                                progressHandler:^(NSString *key, float percent) {
                                                    [self incrementWithProgress:percent];}
                                                         params:@{ @"x:foo":@"fooval" }
                                                       checkCrc:YES
                                             cancellationSignal:nil];
     
     [upManager putData:data key:key token:uploadToken
               complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                   [self.accountManager updateUserInfo:[resp objectForKey:@"url"] withChangeType:ChangeAvatar];
                   [self.accountManager updateUserInfo:[resp objectForKey:@"urlSmall"] withChangeType:ChangeSmallAvatar];
                   
                   
                   NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                   NSMutableArray * userAvatar = [user objectForKey:@"userAvatar"];
                   if (userAvatar == nil) {
                       [user setObject:[NSMutableArray array] forKey:@"userAvatar"];
                       userAvatar = [user objectForKey:@"userAvatar"];
                   }
                   [userAvatar addObject:self.self.accountManager.accountDetail.basicUserInfo.avatarSmall];
                   [user setObject:userAvatar forKey:@"userAvatar"];
//                   NSLog(@"%@--3",userAvatar);
                   [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
//                   NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
//                   UserHeaderTableViewCell *cell = (UserHeaderTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
//                   [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:self.self.accountManager.accountDetail.basicUserInfo.avatarSmall] placeholderImage:nil];
                   
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
            [_tableView reloadData];
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
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                  message:@"确定退出旅行派登录"
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return cellDataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cellDataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    if ((indexPath.section == 0 && indexPath.row == 0)) {
        
        
        return 90;
        
    }
    else if (indexPath.section == 2)
    {

        return 90;
        
    }
    else{
        
        return  49.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
//        UserHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:accountDetailHeaderCell forIndexPath:indexPath];
//        cell.cellLabel.text = cellDataSource[indexPath.section][indexPath.row];
//        cell.testImage.image = [UIImage imageNamed:@"ic_setting_avatar.png"];
//        [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:self.self.accountManager.accountDetail.basicUserInfo.avatarSmall] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.png"]];
        
        HeaderPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"header" forIndexPath:indexPath];
//        NSMutableArray *header = [NSMutableArray array];
//        [header addObject:self.self.accountManager.accountDetail.basicUserInfo.avatarSmall];
//        cell.headerPicArray = header;
        cell.delegate = self;
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSMutableArray * header = [user objectForKey:@"userAvatar"];
        cell.headerPicArray = header;
        return cell;
        
    }
    else if (indexPath.section == 2){
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zuji" forIndexPath:indexPath];
        
        cell.nameLabel.text = @"旅行足迹";
        cell.backgroundColor = [UIColor whiteColor];
        cell.dataArray = @[@"上海",@"北京",@"杭州"];
        return cell;

    }
    else {
        UserOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:otherUserInfoCell forIndexPath:indexPath];
        cell.cellTitle.text = cellDataSource[indexPath.section][indexPath.row];
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_nick.png"];
                cell.cellDetail.text = self.self.accountManager.accountDetail.basicUserInfo.nickName;
            } else if (indexPath.row == 2) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_nick.png"];
//                cell.cellDetail.text = [NSString stringWithFormat:@"%d", [self.self.accountManager.accountDetail.basicUserInfo.userId intValue]];
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                cell.cellDetail.text = [user objectForKey:@"status"];
            }
        } else if (indexPath.section ==  1) {
            if (indexPath.row == 0) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_gender.png"];


            } else if (indexPath.row == 1) {
                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_memo.png"];
                
            }
        }
//        else if (indexPath.section == 2) {
//            if (indexPath.row == 0) {
//                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_password.png"];
//            } else if (indexPath.row == 0) {
//                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_bindphone.png"];
//                NSString *tel = self.self.accountManager.accountDetail.basicUserInfo.tel;
//                if (tel == nil || tel.length < 1) {
//                    cell.cellDetail.text = @"未绑定";
//                } else {
//                    cell.cellDetail.text = tel;
//                }
//            }
        else if (indexPath.section == 3){
        
            cell.cellDetail.text = self.self.accountManager.accountDetail.basicUserInfo.signature;
        }
        else if (indexPath.section == 4) {
            if (indexPath.row == 0){
                
                if ([self.self.accountManager.accountDetail.basicUserInfo.gender isEqualToString:@"F"]) {
                    cell.cellDetail.text = @"美女";
                }
                else if ([self.self.accountManager.accountDetail.basicUserInfo.gender isEqualToString:@"M"]) {
                    cell.cellDetail.text = @"帅锅";
                }
                else if ([self.self.accountManager.accountDetail.basicUserInfo.gender isEqualToString:@"U"]) {
                    cell.cellDetail.text = @"一言难尽";
                }
                else{
                    cell.cellDetail.text = @"保密";
                }
            }
            else if (indexPath.row == 1) {
                cell.cellDetail.text = self.accountManager.accountDetail.birthday;
            } else if (indexPath.row == 2) {
                cell.cellDetail.text = self.accountManager.accountDetail.residence;
            }
            else if (indexPath.row == 3){
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                cell.cellDetail.tag = 101;
                cell.cellDetail.text = [user objectForKey:@"jobs"];
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
            [self changeUserName];
        } else if (indexPath.row == 2) {
//            [self showHint:@"猥琐攻城师不让修改这个～"];
            
            StatusListViewController *svc = [[StatusListViewController alloc]init];
            svc.dataArray = @[@"正在准备旅行",@"旅行中",@"旅行灵感时期",@"不知道"];
            svc.delegate = self;
            [self.navigationController pushViewController:svc animated:YES];
        }
        
    } else if (indexPath.section ==  1) {
        if (indexPath.row == 0) {
            
            [MobClick event:@"event_update_phone"];
            
            VerifyCaptchaViewController *changePasswordCtl = [[VerifyCaptchaViewController alloc] init];
            changePasswordCtl.verifyCaptchaType = UserBindTel;

            [self.navigationController presentViewController:[[TZNavigationViewController alloc] initWithRootViewController:changePasswordCtl] animated:YES completion:nil];
            
            } else if (indexPath.row == 1) {
                [MobClick event:@"event_update_password"];
                ChangePasswordViewController *changePasswordCtl = [[ChangePasswordViewController alloc] init];
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:changePasswordCtl] animated:YES completion:nil];
                
                
//            [MobClick event:@"event_update_memo"];
//            [self changeUserMark];
        }
        
        
    } else if (indexPath.section == 2) {
        
        FootPrintViewController *footCtl = [[FootPrintViewController alloc] init];
//        [self presentViewController:footCtl animated:YES completion:nil];
        [self.navigationController pushViewController:footCtl animated:YES];
        
    } else if (indexPath.section == 3) {
        
        [MobClick event:@"event_update_memo"];
        [self changeUserMark];

    } else if (indexPath.section == 4) {
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
            [self showDatePicker];
        } else if (indexPath.row == 2) {
            NSString *url = [[NSBundle mainBundle] pathForResource:@"DomesticCityDataSource" ofType:@"plist"];
            NSArray *cityArray = [NSArray arrayWithContentsOfFile:url];
            CityListTableViewController *cityListCtl = [[CityListTableViewController alloc] init];
            cityListCtl.cityDataSource = cityArray;
            cityListCtl.needUserLocation = YES;
            TZNavigationViewController *navc = [[TZNavigationViewController alloc] initWithRootViewController:cityListCtl];
            [self presentViewController:navc animated:YES completion:nil];
        }
        else if (indexPath.row == 3){
            JobListViewController *jvc = [[JobListViewController alloc]init];
            jvc.delegate = self;
            jvc.dataArray = @[@"女博士",@"女硕士",@"女北大硕士",@"女清华硕士",@"女清华博士",@"女北大硕士",@"逗比"];
            [self.navigationController pushViewController:jvc animated:YES];
            
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SelectDelegate

- (void)selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath {
    [_tableView reloadData];
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

#pragma mark - http method
- (void) changeUserName {
    BaseTextSettingViewController *bsvc = [[BaseTextSettingViewController alloc] init];
    bsvc.navTitle = @"修改名字";
    bsvc.content = self.accountManager.accountDetail.basicUserInfo.nickName;
    bsvc.acceptEmptyContent = NO;
    bsvc.saveEdition = ^(NSString *editText, saveComplteBlock(completed)) {
        [self updateUserInfo:ChangeName withNewContent:editText success:completed];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:bsvc] animated:YES completion:nil];
}

- (void)changeUserMark {
    BaseTextSettingViewController *bsvc = [[BaseTextSettingViewController alloc] init];
    bsvc.navTitle = @"个性签名";
    bsvc.content = self.accountManager.accountDetail.basicUserInfo.signature;
    bsvc.acceptEmptyContent = YES;
    bsvc.saveEdition = ^(NSString *editText, saveComplteBlock(completed)) {
        [self updateUserInfo:ChangeSignature withNewContent:editText success:completed];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:bsvc] animated:YES completion:nil];
}

- (void)updateUserInfo:(UserInfoChangeType)changeType withNewContent:(NSString *)newText success:(saveComplteBlock)completed
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (changeType == ChangeName) {
        [accountManager asyncChangeUserName:newText completion:^(BOOL isSuccess, UserInfoInputError error, NSString *errStr) {
            if (isSuccess) {
                completed(YES);
            } else if (error != NoError){
                [SVProgressHUD showHint:@"名字不能是纯数字或包含特殊字符"];
                completed(NO);
            } else if (errStr){
                [SVProgressHUD showHint:errStr];
                completed(NO);
            } else {
                [SVProgressHUD showHint:@"呃～好像没找到网络"];
                completed(NO);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
    } else if (changeType == ChangeSignature) {
        [accountManager asyncChangeSignature:newText completion:^(BOOL isSuccess, UserInfoInputError error, NSString *errStr) {
            if (isSuccess) {
                completed(YES);
            } else if (errStr){
                [SVProgressHUD showHint:errStr];
                completed(NO);
            } else {
                [SVProgressHUD showHint:@"呃～好像没找到网络"];
                completed(NO);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }
}
-(void)showPickerView
{
    [self presentImagePicker];
}
-(void)changeJob:(NSString *)jobStr
{
//    UILabel *cell  = (UILabel *)[self.tableView viewWithTag:101];
//    cell.text = jobStr;
    [_tableView reloadData];
}
-(void)changeStatus
{
    [_tableView reloadData];
}


@end



