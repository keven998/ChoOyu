//
//  EditUserInfoTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/14.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <QiniuSDK.h>
#import "EditUserInfoTableViewController.h"
#import "UserHeaderTableViewCell.h"
#import "ChangePasswordViewController.h"
#import "AccountManager.h"
#import "UserOtherTableViewCell.h"
#import "VerifyCaptchaViewController.h"
#import "JGProgressHUDPieIndicatorView.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "FootPrintViewController.h"
#import "CityListTableViewController.h"
#import "SelectionTableViewController.h"
#import "PXAlertView+Customization.h"
#import "BaseTextSettingViewController.h"
#import "JobListViewController.h"
#import "HeaderCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "AIDatePickerController.h"
#import "SignatureViewController.h"
#import "DomesticViewController.h"
#import "ForeignViewController.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "PicCell.h"
#import "PlansListTableViewController.h"
#import "MWPhotoBrowser.h"
#import "UserAlbumViewController.h"
#import "EditUserSignatureViewController.h"

#define accountDetailHeaderCell          @"headerCell"
#define otherUserInfoCell           @"otherCell"

#define cellDataSource              @[@[@"头像"], @[@"名字", @"性别", @"生日", @"现住地"], @[@"填写签名"], @[@"足迹", @"相册"],@[@"安全设置", @"修改密码"]]

@interface EditUserInfoTableViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, SelectDelegate, ChangJobDelegate>

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) AccountManager *accountManager;
@property (strong, nonatomic) Destinations *destinations;


// 我的足迹的描述
@property (nonatomic, copy) NSString *tracksDesc;

@property (nonatomic, strong) JGProgressHUD *HUD;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSMutableArray *footPrintArray;

@property (nonatomic, assign) NSInteger updateUserInfoType; //修改用户信息封装的补丁

@end

@implementation EditUserInfoTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"编辑资料";
    
    [self updateDestinations];
    [self loadUserAlbum];
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
    
    NSString *key = [NSString stringWithFormat:@"%@_%ld", kShouldShowFinishUserInfoNoti, [AccountManager shareAccountManager].account.userId];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"page_edit_my_profile"];
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"page_edit_my_profile"];
    [super viewWillDisappear:animated];
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

- (Destinations *)updateDestinations
{
    _destinations = [[Destinations alloc] init];
    AccountManager *amgr = self.accountManager;
    _destinations.destinationsSelected = amgr.account.footprints;
    return _destinations;
}

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 72)];
        
        UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(12.0, 20.0, self.view.bounds.size.width - 24.0, 52.0)];
        logoutBtn.center = _footerView.center;
        logoutBtn.layer.cornerRadius = 4.0;
        logoutBtn.clipsToBounds = YES;
        [logoutBtn setBackgroundImage:[[UIImage imageNamed:@"chat_drawer_leave.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
        
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
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    NSString *url = [NSString stringWithFormat:@"%@%ld/albums", API_USERS, accountManager.account.userId];
    
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

/*
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
    accountManager.account.userAlbum = array;
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
    [alertView useCustomStyle];
    
    [alertView setBackgroundColor:[UIColor whiteColor]];
    
    
    // 设置其他按钮的颜色
    UIColor * otherNormal = TEXT_COLOR_TITLE;
    UIColor * otherSeleced = APP_THEME_COLOR;
    [alertView setAllButtonsTextColor:otherNormal andHighLightedColor:otherSeleced];
    
    // 设置取消按钮的颜色
    UIColor *cancelNormal = TEXT_COLOR_TITLE;
    UIColor *cancelSelected = TEXT_COLOR_TITLE;
    [alertView setCancelButtonTextColor:cancelNormal andHighLightedColor:cancelSelected];
    
    // 设置取消按钮的下划线
    [alertView setCancelUnderlineWithColor:COLOR_LINE];
}

/**
 *  显示选择日期选择器
 */
- (void)showDatePicker
{
    NSDate *birthday = [ConvertMethods stringToDate:self.accountManager.account.birthday withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
    __weak EditUserInfoTableViewController *weakSelf = self;
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:birthday selectedBlock:^(NSDate *selectedDate) {
        __strong EditUserInfoTableViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        
        [self confirmDatePick:selectedDate];
    } cancelBlock:^{
        __strong EditUserInfoTableViewController *strongSelf = weakSelf;
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
    __weak typeof(EditUserInfoTableViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)self.accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    [manager GET:API_POST_PHOTOIMAGE parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
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
                  NSString *url = [resp objectForKey:@"url"];
                  NSString *urlSmall = [resp objectForKey:@"urlSmall"];
                  _accountManager.account.avatar = url;
                  _accountManager.account.avatarSmall = urlSmall;
                  [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
                  
              } option:opt];
    
}

- (JGProgressHUD *)HUD
{
    if (!_HUD) {
        _HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        _HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] initWithHUDStyle:JGProgressHUDStyleDark];
        _HUD.detailTextLabel.text = nil;
        _HUD.textLabel.text = @"正在上传";
        _HUD.layoutChangeAnimationDuration = 0.0;
    }
    return _HUD;
}

- (void)incrementWithProgress:(float)progress
{
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
- (void)updateUserGender:(NSInteger )gender
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (gender == accountManager.account.gender) {
        return;
    }
    __weak typeof(EditUserInfoTableViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    NSString *genderStr = [NSString stringWithFormat:@"%lu",gender];
    [accountManager asyncChangeGender:genderStr completion:^(BOOL isSuccess, NSString *errStr) {
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return cellDataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cellDataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 85;
    }
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountManager *amgr = self.accountManager;
    if (indexPath.section == 0) {
        UserHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:accountDetailHeaderCell forIndexPath:indexPath];
        [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString: amgr.account.avatarSmall] placeholderImage:[UIImage imageNamed:@"avatar_default.png"]];
        return cell;

    } else {
        UserOtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:otherUserInfoCell forIndexPath:indexPath];
        cell.cellTitle.text = cellDataSource[indexPath.section][indexPath.row];
        self.tracksDesc = self.accountManager.account.footprintsDesc;
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.cellDetail.text = amgr.account.nickName;
                
            } else if (indexPath.row == 1) {
                if (amgr.account.gender ==Female) {
                    cell.cellDetail.text = @"美女";
                }
                else if (amgr.account.gender == Male) {
                    cell.cellDetail.text = @"帅锅";
                }
                else if (amgr.account.gender == Unknown) {
                    cell.cellDetail.text = @"一言难尽";
                }
                else {
                    cell.cellDetail.text = @"保密";
                }
                
            } else if (indexPath.row == 2) {
                if (amgr.account.birthday.length == 0 || amgr.account.birthday == nil) {
                    cell.cellDetail.text = @"未设置";
                } else {
                    cell.cellDetail.text = amgr.account.birthday;
                }
                
            } else if (indexPath.row == 3) {
                if (amgr.account.residence == nil || amgr.account.residence.length == 0) {
                    cell.cellDetail.text = @"未设置";
                } else {
                    cell.cellDetail.text = amgr.account.residence;
                }
            }
            
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                if (![amgr.account.signature isBlankString]) {
                    cell.cellDetail.text = amgr.account.signature;
                } else {
                    cell.cellDetail.text = @"未设置";
                }
            }
        } else if (indexPath.section == 3) {
           if (indexPath.row == 0) {
                if (_tracksDesc) {
                    cell.cellDetail.text = _tracksDesc;
                } else {
                    cell.cellDetail.text = @"未设置";
                }
                
            } else if (indexPath.row == 1) {
                if (amgr.account.userAlbum.count) {
                    cell.cellDetail.text = [NSString stringWithFormat:@"%zd张",amgr.account.userAlbum.count];
                } else {
                    cell.cellDetail.text = @"0张";
                }
            }
        } else {
            if (indexPath.row == 0) {
                if (amgr.accountIsBindTel) {
                    cell.cellDetail.text = @"已绑定";
                    
                } else {
                    cell.cellDetail.text = @"未设置";
                }
                
            } else {
                cell.cellDetail.text = @"";
            }
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self changeUserAvatar];
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self changeUserName];
            
        } else if (indexPath.row == 1) {
            SelectionTableViewController *ctl = [[SelectionTableViewController alloc] init];
            ctl.contentItems = @[@"美女", @"帅锅", @"一言难尽", @"保密"];
            ctl.titleTxt = @"性别设置";
            ctl.delegate = self;
            UserOtherTableViewCell *uc = (UserOtherTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            ctl.selectItem = uc.cellDetail.text;
            TZNavigationViewController *nav = [[TZNavigationViewController alloc] initWithRootViewController:ctl];
            _updateUserInfoType = 1;
            [self presentViewController:nav animated:YES completion:nil];
            
        } else if (indexPath.row == 2) {
            [self showDatePicker];
        } else if (indexPath.row == 3) {
            NSString *url = [[NSBundle mainBundle] pathForResource:@"DomesticCityDataSource" ofType:@"plist"];
            NSArray *cityArray = [NSArray arrayWithContentsOfFile:url];
            CityListTableViewController *cityListCtl = [[CityListTableViewController alloc] init];
            cityListCtl.cityDataSource = cityArray;
            cityListCtl.needUserLocation = YES;
            TZNavigationViewController *navc = [[TZNavigationViewController alloc] initWithRootViewController:cityListCtl];
            [self presentViewController:navc animated:YES completion:nil];
            
        }
        
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self changeUserMark];
        }
        
    } else if (indexPath.section == 3) {
       if (indexPath.row == 0) {
            FootPrintViewController *footCtl = [[FootPrintViewController alloc] init];
            footCtl.userId = self.accountManager.account.userId;
            [self.navigationController pushViewController:footCtl animated:YES];
        } else if (indexPath.row == 1) {
            [self viewUserPhotoAlbum];
        }
    } else {
        if (indexPath.row == 0) {
            VerifyCaptchaViewController *changePasswordCtl = [[VerifyCaptchaViewController alloc] init];
            changePasswordCtl.verifyCaptchaType = UserBindTel;
            [self.navigationController presentViewController:[[TZNavigationViewController alloc] initWithRootViewController:changePasswordCtl] animated:YES completion:nil];
           
        } else if (indexPath.row == 1) {
            ChangePasswordViewController *changePasswordCtl = [[ChangePasswordViewController alloc] init];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:changePasswordCtl] animated:YES completion:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SelectDelegate

- (void)selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath
{
    if (_updateUserInfoType == 1) {
        [self updateGender:indexPath];
    } else if(_updateUserInfoType == 2){
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

- (void)updateGender:(NSIndexPath *)selectIndex
{
    NSString *str;
    if (selectIndex.row == 0) {
        str = @"F";
    }else if (selectIndex.row == 1){
        str = @"M";
    }else if (selectIndex.row == 2){
        str = @"B";
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

#pragma mark - action method


- (void)changeUserAvatar
{
    [self presentImagePicker];
}

- (void)changeUserName
{
    BaseTextSettingViewController *bsvc = [[BaseTextSettingViewController alloc] init];
    bsvc.navTitle = @"修改名字";
    bsvc.content = self.accountManager.account.nickName;
    bsvc.acceptEmptyContent = NO;
    // 给block赋值
    bsvc.saveEdition = ^(NSString *editText, saveComplteBlock(completed)) {
        [self updateUserInfo:ChangeName withNewContent:editText success:completed];
    };
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:bsvc] animated:YES completion:nil];
}

- (void)changeAvatar:(NSInteger)index
{
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:self.navigationController content:64];
    AlbumImage *image = [self.accountManager.account.userAlbum objectAtIndex:index];
    [self.accountManager asyncChangeUserAvatar:image completion:^(BOOL isSuccess, NSString *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
        [hud hideTZHUD];
    }];
}

- (void)viewUserPhotoAlbum
{
    UserAlbumViewController *ctl = [[UserAlbumViewController alloc] initWithNibName:@"UserAlbumViewController" bundle:nil];
    ctl.albumArray = [self.accountManager.account.userAlbum mutableCopy];
    ctl.isMyself = YES;
    ctl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctl animated:YES];
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
    AlbumImage *image = [self.accountManager.account.userAlbum objectAtIndex:index];
    [self.accountManager asyncDelegateUserAlbumImage:image completion:^(BOOL isSuccess, NSString *error) {
        [hud hideTZHUD];
    }];
}

- (void)changeUserMark
{
    EditUserSignatureViewController *ctl = [[EditUserSignatureViewController alloc] init];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
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
                [SVProgressHUD showHint:@"名字不能是纯数字"];
                completed(NO);
            } else if (errStr){
                [SVProgressHUD showHint:errStr];
                completed(NO);
            } else {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *headerImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self uploadPhotoImage:headerImage];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [SVProgressHUD show];
        [accountManager asyncLogout:^(BOOL isSuccess) {
            if (isSuccess) {
                [self showHint:@"退出成功"];
                [self.navigationController popViewControllerAnimated:YES];
                
                [self.tabBarController setSelectedIndex:1];
            } else {
                [self showHint:@"退出失败"];
            }
        }];
    }
}

@end











