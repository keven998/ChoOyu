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
#import "HeaderCell.h"
#import "HeaderPictureCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "AIDatePickerController.h"
#import "SignatureViewController.h"
#import "DomesticViewController.h"
#import "ForeignViewController.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

#define accountDetailHeaderCell          @"headerCell"
#define otherUserInfoCell           @"otherCell"

#define cellDataSource              @[@[@"头像", @"名字", @"状态"], @[@"我的足迹"], @[@"签名"], @[@"性别", @"生日", @"居住在"], @[@"安全绑定", @"修改密码"], ]

@interface UserInfoTableViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, SelectDelegate, ChangJobDelegate, HeaderPictureDelegate>
{
    Destinations *_citySelectedArray;
}
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) AccountManager *accountManager;

@property (nonatomic, strong) JGProgressHUD *HUD;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSMutableArray *footPrintArray;

@property (nonatomic, assign) NSInteger updateUserInfoType; //修改用户信息封装的补丁

@end

@implementation UserInfoTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我";
    
    [self loadUserInfo];
    
    _citySelectedArray = [[Destinations alloc]init];
    
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
            [self loadUserAlbum];
        }
    }];
}

/**
 *  下载用户头像列表
 */
- (void)loadUserAlbum
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    NSString *url = [NSString stringWithFormat:@"%@%@/albums", API_USERINFO, accountManager.account.userId];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self paraseUserAlbum:[responseObject objectForKey:@"result"]];
            [self.tableView reloadData];
        } else {
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView reloadData];
    }];

}

/**
 *  解析用户头像列表
 *
 *  @param albumArray
 */
- (void)paraseUserAlbum:(NSArray *)albumArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (id album in albumArray) {
        [array addObject:[[AlbumImage alloc] initWithJson:album]];
    }
    AccountManager *accountManager = [AccountManager shareAccountManager];
    accountManager.accountDetail.userAlbum = array;
    NSLog(@"%@",array);
}

- (void)presentImagePicker
{
    PXAlertView *alertView = [PXAlertView showAlertWithTitle:nil
                                                     message:nil
                                                 cancelTitle:@"取消"
                                                 otherTitles:@[@"拍照", @"相册"]
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
    NSDate *birthday = [ConvertMethods stringToDate:self.accountManager.accountDetail.birthday withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
    __weak UserInfoTableViewController *weakSelf = self;
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:birthday selectedBlock:^(NSDate *selectedDate) {
        __strong UserInfoTableViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        
        [self confirmDatePick:selectedDate];
    } cancelBlock:^{
        __strong UserInfoTableViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}

/**
 *  确定日期选择
 *
 *  @param sender
 */
- (void)confirmDatePick:(NSDate *)selectedDate
{
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInView:self.view];
    
    NSString *dataStr = [ConvertMethods dateToString:selectedDate withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
    [self.accountManager asyncChangeBirthday:dataStr completion:^(BOOL isSuccess, NSString *errStr) {
        [hud hideTZHUD];
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
    
    [manager GET:API_POST_PHOTOALBUM parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
 *  将图片上传至七牛服务器
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
                  
                  AlbumImage *image = [[AlbumImage alloc] init];
                  image.imageId = [resp objectForKey:@"id"];
                  image.image.imageUrl = [resp objectForKey:@"url"];
                  NSMutableArray *mutableArray = [self.accountManager.accountDetail.userAlbum mutableCopy];
                  [mutableArray addObject:image];
                  self.accountManager.accountDetail.userAlbum = mutableArray;
                  [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
                  
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

    if ((indexPath.section == 0 && indexPath.row == 0))
    {
        return 108;
    }
    else if (indexPath.section == 1 || indexPath.section == 2)
    {
        
        return 84;
        
    }
    else{
        
        return  49.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountManager *amgr = self.accountManager;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        HeaderPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"header" forIndexPath:indexPath];
        cell.headerPicArray = amgr.accountDetail.userAlbum;
        NSLog(@"%@",cell.headerPicArray);
        cell.delegate = self;
        return cell;
        
    } else if (indexPath.section == 1) {
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zuji" forIndexPath:indexPath];
        cell.nameLabel.text = @"我的足迹";
        NSDictionary *country = amgr.accountDetail.tracks;
        NSInteger cityNumber = 0;
        NSMutableString *cityDesc = nil;
        NSArray *keys = [country allKeys];
        NSInteger countryNumber = keys.count;
        for (int i = 0; i < countryNumber; ++i) {
            NSArray *citys = [country objectForKey:[keys objectAtIndex:i]];
            NSLog(@"%@",citys);
            cityNumber += citys.count;
            for (id city in citys) {
//                city
                CityDestinationPoi *poi = [[CityDestinationPoi alloc] initWithJson:city];
                [_citySelectedArray.destinationsSelected addObject:poi];
                if (cityDesc == nil) {
                    cityDesc = [[NSMutableString alloc] initWithString:[city objectForKey:@"zhName"]];
                } else {
                    [cityDesc appendFormat:@" %@", [city objectForKey:@"zhName"]];
                }
            }
        }
        
        if (countryNumber > 0) {
            cell.trajectory.text = [NSString stringWithFormat:@"%ld国 %ld个城市", (long)countryNumber, (long)cityNumber];
            cell.footPrint.text = cityDesc;
        } else {
            cell.trajectory.text = [NSString stringWithFormat:@"%ld国 %ld个城市", (long)countryNumber, (long)cityNumber];
            cell.footPrint.text = @"未设置足迹";
        }
        
        return cell;
        
    } else if (indexPath.section == 2) {
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zuji" forIndexPath:indexPath];
        cell.nameLabel.text = @"签名";
        cell.trajectory.textColor = TEXT_COLOR_TITLE_DESC;
        if([self.accountManager.accountDetail.basicUserInfo.signature isBlankString]||self.accountManager.accountDetail.basicUserInfo.signature.length == 0) {
            cell.footPrint.text = @"未设置签名";
        }else {
            cell.footPrint.text = self.accountManager.accountDetail.basicUserInfo.signature;
        }
        return cell;
        
    } else {
        UserOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:otherUserInfoCell forIndexPath:indexPath];
        cell.cellTitle.text = cellDataSource[indexPath.section][indexPath.row];
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                
                cell.cellDetail.text = amgr.account.nickName;
            } else if (indexPath.row == 2) {
                cell.cellDetail.text = amgr.accountDetail.travelStatus;
            }
            
        } else if (indexPath.section == 3) {
            if (indexPath.row == 0){
                if ([amgr.accountDetail.basicUserInfo.gender isEqualToString:@"F"]) {
                    cell.cellDetail.text = @"美女";
                }
                else if ([amgr.accountDetail.basicUserInfo.gender isEqualToString:@"M"]) {
                    cell.cellDetail.text = @"帅锅";
                }
                else if ([amgr.accountDetail.basicUserInfo.gender isEqualToString:@"U"]) {
                    cell.cellDetail.text = @"一言难尽";
                }
                else {
                    cell.cellDetail.text = @"保密";
                }
                
            } else if (indexPath.row == 1) {
                if (amgr.accountDetail.birthday.length == 0 || amgr.accountDetail.birthday == nil) {
                    cell.cellDetail.text = @"未设置";
                } else {
                cell.cellDetail.text = amgr.accountDetail.birthday;
                }
                
            } else if (indexPath.row == 2) {
                if (amgr.accountDetail.residence.length == 0) {
                    cell.cellDetail.text = @"未设置";
                    
                } else {
                cell.cellDetail.text = amgr.accountDetail.residence;
                }
            }
        }
        else if (indexPath.section ==  4) {
            if (indexPath.row == 0) {
                if (amgr.accountIsBindTel) {
                    cell.cellDetail.text = @"已安全绑定";
                } else {
                    cell.cellDetail.text = @"设置";
                }
            } else if (indexPath.row == 1) {
                //                cell.cellImage.image = [UIImage imageNamed:@"ic_setting_memo.png"];
                cell.cellDetail.text = @"";
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
            
            SelectionTableViewController *svc = [[SelectionTableViewController alloc]init];
            svc.contentItems = @[@"准备去旅行", @"旅行中", @"旅行灵感中", @"不知道"];
            svc.titleTxt = @"旅行状态";
            svc.delegate = self;
            UserOtherTableViewCell *uc = (UserOtherTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            svc.selectItem = uc.cellDetail.text;
            TZNavigationViewController *nav = [[TZNavigationViewController alloc] initWithRootViewController:svc];
            _updateUserInfoType = 2;
            [self presentViewController:nav animated:YES completion:nil];
        }
        
    } else if (indexPath.section == 1) {
        
        FootPrintViewController *footCtl = [[FootPrintViewController alloc] init];
        footCtl.destinations = _citySelectedArray;
        [self presentViewController:footCtl animated:YES completion:nil];
        
    } else if (indexPath.section == 2) {
        
        [MobClick event:@"event_update_memo"];
        [self changeUserMark];
        
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [MobClick event:@"event_update_gender"];
            SelectionTableViewController *ctl = [[SelectionTableViewController alloc] init];
            ctl.contentItems = @[@"美女", @"帅锅", @"一言难尽", @"保密"];
            ctl.titleTxt = @"我是";
            ctl.delegate = self;
            UserOtherTableViewCell *uc = (UserOtherTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            ctl.selectItem = uc.cellDetail.text;
            TZNavigationViewController *nav = [[TZNavigationViewController alloc] initWithRootViewController:ctl];
            _updateUserInfoType = 1;
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
        //        else if (indexPath.row == 3){
        //            JobListViewController *jvc = [[JobListViewController alloc]init];
        //            jvc.delegate = self;
        //            jvc.dataArray = @[@"女博士",@"女硕士",@"女北大硕士",@"女清华硕士",@"女清华博士",@"女北大硕士",@"逗比"];
        //            [self.navigationController pushViewController:jvc animated:YES];
        //
        //        }
    } else if (indexPath.section ==  4) {
        if (indexPath.row == 0) {
            [MobClick event:@"event_update_phone"];
            VerifyCaptchaViewController *changePasswordCtl = [[VerifyCaptchaViewController alloc] init];
            changePasswordCtl.verifyCaptchaType = UserBindTel;
            
            [self.navigationController presentViewController:[[TZNavigationViewController alloc] initWithRootViewController:changePasswordCtl] animated:YES completion:nil];
        } else if (indexPath.row == 1) {
            [MobClick event:@"event_update_password"];
            ChangePasswordViewController *changePasswordCtl = [[ChangePasswordViewController alloc] init];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:changePasswordCtl] animated:YES completion:nil];
        }
        
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SelectDelegate

- (void)selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath
{
    //    [_tableView reloadData];
    if (_updateUserInfoType == 1) {
        [self updateGender:indexPath];
    }else if(_updateUserInfoType == 2){
        [self updateStatus:str];
    }
}

- (void)updateStatus:(NSString *)str
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInView:self.view];
    [accountManager asyncChangeStatus:str completion:^(BOOL isSuccess, NSString *errStr) {
        if (!isSuccess) {
            [SVProgressHUD showHint:@"网络请求失败"];
        }
        [hud hideTZHUD];
    }];
    [self.tableView reloadData];
}

- (void) updateGender:(NSIndexPath *)selectIndex
{
    NSString *str = [[NSString alloc]init];
    if (selectIndex.row == 0) {
        str = @"F";
    }else if (selectIndex.row == 1){
        str = @"M";
    }else if (selectIndex.row == 2){
        str = @"U";
    } else {
        str = @"S";
    }
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInView:self.view];
    
    [accountManager asyncChangeGender:str completion:^(BOOL isSuccess, NSString *errStr) {
        if (!isSuccess) {
            [SVProgressHUD showHint:@"网络请求失败"];
        }
        [hud hideTZHUD];
    }];
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
- (void)changeUserName
{
    BaseTextSettingViewController *bsvc = [[BaseTextSettingViewController alloc] init];
    bsvc.navTitle = @"修改名字";
    bsvc.content = self.accountManager.account.nickName;
    bsvc.acceptEmptyContent = NO;
    bsvc.saveEdition = ^(NSString *editText, saveComplteBlock(completed)) {
        [self updateUserInfo:ChangeName withNewContent:editText success:completed];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:bsvc] animated:YES completion:nil];
}

- (void)changeAvatar:(NSInteger)index
{
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInView:self.view];
    AlbumImage *image = [self.accountManager.accountDetail.userAlbum objectAtIndex:index];
    [self.accountManager asyncChangeUserAvatar:image completion:^(BOOL isSuccess, NSString *error) {
        [hud hideTZHUD];
    }];
}

/**
 *  删除用户头像
 *
 *  @param index 
 */
- (void)deleteUserAvatar:(NSInteger)index
{
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInView:self.view];
    AlbumImage *image = [self.accountManager.accountDetail.userAlbum objectAtIndex:index];
    [self.accountManager asyncDelegateUserAlbumImage:image completion:^(BOOL isSuccess, NSString *error) {
        [hud hideTZHUD];
    }];
}

- (void)changeUserMark
{
    SignatureViewController *bsvc = [[SignatureViewController alloc]init];
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

- (void)changeJob:(NSString *)jobStr
{
    [_tableView reloadData];
}

- (void)changeStatus
{
    [_tableView reloadData];
}

#pragma mark - HeaderPictureDelegate
- (void)showPickerView
{
    [self presentImagePicker];
}

- (void)editAvatar:(NSInteger)index
{
    PXAlertView *alertView = [PXAlertView showAlertWithTitle:nil
                                                     message:nil
                                                 cancelTitle:@"取消"
                                                 otherTitles:@[ @"设为头像", @"查看图片", @"删除"]
                                                  completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                      if (buttonIndex == 1) {
                                                          
                                                          [self changeAvatar:index];
                                                          
                                                      } else if (buttonIndex == 2) {
                                                          
                                                          [self showImageDetail:index];
                                                          
                                                      } else if (buttonIndex == 3) {
                                                          
                                                          [self deleteUserAvatar:index];
                                                          
                                                      }
                                                  }];
    [alertView setTitleFont:[UIFont systemFontOfSize:16]];
    [alertView useDefaultIOS7Style];
}
//      AlbumImage *albumImage = _headerPicArray[indexPath.row];
//      [cell.picImage sd_setImageWithURL:[NSURL URLWithString: albumImage.image.imageUrl]];
-(void)showImageDetail:(NSInteger)index
{
    AccountManager *amgr = self.accountManager;
    NSInteger count = amgr.accountDetail.userAlbum.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        AlbumImage *albumImage = amgr.accountDetail.userAlbum[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:albumImage.image.imageUrl]; // 图片路径
//        photo.srcImageView = (UIImageView *)[swipeView itemViewAtIndex:index]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];

}
@end











