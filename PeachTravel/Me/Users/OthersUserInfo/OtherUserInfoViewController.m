//
//  OtherUserInfoViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/5/16.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "OtherUserInfoViewController.h"
#import "MyGuideListTableViewController.h"
#import "HeaderCell.h"
#import "OtherUserBasicInfoCell.h"
#import "OthersAlbumCell.h"
#import "TraceViewController.h"
#import "ChatViewController.h"
#import "ChatSettingViewController.h"
#import "AccountModel.h"
#import "UIBarButtonItem+MJ.h"
#import "REFrostedViewController.h"

@interface OtherUserInfoViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UIImageView *_headerView;
    BOOL _isMyFriend;
    NSMutableArray *_albumArray;
}
@end

@implementation OtherUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _albumArray = [NSMutableArray array];
    AccountManager *accountManager = [AccountManager shareAccountManager];

    _isMyFriend = [accountManager isMyFrend: _userId];
    
    if (_isMyFriend) {
        UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        [moreBtn setImage:[UIImage imageNamed:@"ic_more.png"] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        [moreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    }
    
    [self loadUserProfile:_userId];
    [self loadUserAlbum];
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [NSMutableArray array];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.separatorColor = APP_DIVIDER_COLOR;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HeaderCell" bundle:nil] forCellReuseIdentifier:@"zuji"];
     [_tableView registerNib:[UINib nibWithNibName:@"OtherUserBasicInfoCell" bundle:nil] forCellReuseIdentifier:@"basicInfoCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OthersAlbumCell" bundle:nil] forCellReuseIdentifier:@"albumCell"];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    [self.view addSubview:_tableView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)createHeader
{
    _headerView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 94)];
//    _headerView.image = [UIImage imageNamed:@"picture_background"];
    _headerView.userInteractionEnabled = YES;
    _headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 17, 60, 60)];
    avatarView.clipsToBounds = YES;
    avatarView.backgroundColor = APP_IMAGEVIEW_COLOR;
    avatarView.layer.cornerRadius = 18;
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [_headerView addSubview:avatarView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 17, 0, 21)];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = TEXT_COLOR_TITLE;
    [_headerView addSubview:nameLabel];
    
//    UILabel *statusLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, 13, 13)];
//    statusLable.font = [UIFont systemFontOfSize:10];
//    statusLable.textColor = [UIColor whiteColor];
//    statusLable.backgroundColor = APP_THEME_COLOR;
//    statusLable.layer.cornerRadius = 2.0;
//    statusLable.textAlignment = NSTextAlignmentCenter;
//    statusLable.clipsToBounds = YES;
//    [_headerView addSubview:statusLable];
    
    UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, 0, 13)];
    levelLabel.textColor = [UIColor whiteColor];
    levelLabel.font = [UIFont systemFontOfSize:10];
    levelLabel.backgroundColor = APP_THEME_COLOR;
    levelLabel.textAlignment = NSTextAlignmentCenter;
    levelLabel.layer.cornerRadius = 2.0;
    levelLabel.clipsToBounds = YES;
    [_headerView addSubview:levelLabel];
    
    UILabel *constellationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, 0, 13)];
    constellationLabel.textColor = TEXT_COLOR_TITLE;
    constellationLabel.font = [UIFont systemFontOfSize:12];
    constellationLabel.text = [_model getConstellation];
    [_headerView addSubview:constellationLabel];
    
    UIImageView *genderImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 19, 15, 15)];
    genderImage.contentMode = UIViewContentModeCenter;
    if ([_model.gender isEqualToString:@"F"]) {
        genderImage.image = [UIImage imageNamed:@"girl"];
        [_headerView addSubview:genderImage];
    } else if([_model.gender isEqualToString:@"M"]) {
        genderImage.image = [UIImage imageNamed:@"boy"];
        [_headerView addSubview:genderImage];
    }
    
    [avatarView sd_setImageWithURL:[NSURL URLWithString:_model.avatarSmall]];
    nameLabel.text = _model.name;
    
    UILabel *taoziId = [[UILabel alloc]initWithFrame:CGRectMake(96, CGRectGetMaxY(nameLabel.frame)+2, 200, 16)];
    taoziId.font = [UIFont systemFontOfSize:13];
    taoziId.textColor = TEXT_COLOR_TITLE_DESC;
    NSString *taoziIdStr = [NSString stringWithFormat:@"ID %@",_model.userId];
    taoziId.text = taoziIdStr;
    [_headerView addSubview:taoziId];
    
    UILabel *signatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, CGRectGetMaxY(taoziId.frame)+2, CGRectGetWidth(self.view.bounds) - 100, 18)];
    signatureLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    signatureLabel.font = [UIFont systemFontOfSize:12];
    signatureLabel.textColor = TEXT_COLOR_TITLE_DESC;
    signatureLabel.text = _model.signature;
    [_headerView addSubview:signatureLabel];
    
    levelLabel.text = [NSString stringWithFormat:@"V%ld", _model.level];

    CGSize levelSize = [levelLabel.text boundingRectWithSize:CGSizeMake(100, 15)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{
                                                                NSFontAttributeName : [UIFont systemFontOfSize:10]
                                                                }
                                                      context:nil].size;
    
    CGSize conSize = [constellationLabel.text boundingRectWithSize:CGSizeMake(100, 15)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{
                                                               NSFontAttributeName : [UIFont systemFontOfSize:12]
                                                               }
                                                     context:nil].size;
    
    CGFloat maxSize = CGRectGetWidth(self.view.bounds) - 240;
    CGSize nameSize = [nameLabel.text boundingRectWithSize:CGSizeMake(maxSize, 21)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{
                                                              NSFontAttributeName : [UIFont systemFontOfSize:16]
                                                              }
                                                    context:nil].size;
    
    CGRect nf = nameLabel.frame;
    nf.size.width = nameSize.width;
    nameLabel.frame = nf;
    
    CGRect llf = levelLabel.frame;
    llf.size.width = levelSize.width + 5;
    llf.origin.x = 5 + CGRectGetMaxX(nf);
    levelLabel.frame = llf;
    
    CGFloat ox = CGRectGetMaxX(llf);

    if (genderImage.image != nil) {
        CGRect gif = genderImage.frame;
        gif.origin.x = ox + 5;
        genderImage.frame = gif;
        ox += 20;
    }
    
    CGRect rect = constellationLabel.frame;
    rect.size.width = conSize.width;
    rect.origin.x = ox + 5;
    constellationLabel.frame = rect;
    
     _tableView.tableHeaderView = _headerView;
}

-(void)createFooterBar
{
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, CGRectGetWidth(self.view.bounds), 49)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:toolBar];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isMyFrend:_userId]) {
        UIButton *addFriend = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 49)];
        [addFriend setTitle:@"开始聊天" forState:UIControlStateNormal];
        [addFriend setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [addFriend setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
        [addFriend addTarget:self action:@selector(talkToFriend) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:addFriend];

    } else {
        UIButton *addFriend = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 49)];
        [addFriend setTitle:@"加为好友" forState:UIControlStateNormal];
        [addFriend setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [addFriend setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
        [addFriend addTarget:self action:@selector(addToFriend) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:addFriend];
    }
    
//    UIButton *consultingBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-1, 0, SCREEN_WIDTH/2, 49)];
//    [consultingBtn setTitle:@"咨询达人" forState:UIControlStateNormal];
//    consultingBtn.backgroundColor = [UIColor whiteColor];
//    [consultingBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
//    [consultingBtn addTarget:self action:@selector(sendRequest) forControlEvents:UIControlEventTouchUpInside];
//    [toolBar addSubview:consultingBtn];
}

#pragma mark - IBAction
- (void) addToFriend {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"输入好友验证申请" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *nameTextField = [alert textFieldAtIndex:0];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    nameTextField.text = [NSString stringWithFormat:@"Hi, 我是%@", accountManager.account.nickName];
    [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self requestAddContactWithHello:nameTextField.text];
        }
    }];
}
- (void) talkToFriend {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:_model.easemobUser isGroup:NO];
    chatCtl.title = accountManager.account.nickName;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    for (EMConversation *conversation in conversations) {
        if ([conversation.chatter isEqualToString:accountManager.account.easemobUser]) {
            [conversation markAllMessagesAsRead:YES];
            break;
        }
    }
    UIViewController *menuViewController = [[ChatSettingViewController alloc] init];
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:chatCtl menuViewController:menuViewController];
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.resumeNavigationBar = NO;
    frostedViewController.limitMenuViewSize = YES;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
    [self.navigationController pushViewController:frostedViewController animated:YES];
}

- (IBAction)moreAction:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"删除", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [MobClick event:@"event_delete_it"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认删除好友？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self removeContact];
            }
        }];
    }
}

- (void)removeContact
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_DELETE_CONTACTS, _userId];
    
    __weak typeof(OtherUserInfoViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    //删除联系人
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [accountManager removeContact:_userId];
            [SVProgressHUD showHint:@"已删除～"];
            [[NSNotificationCenter defaultCenter] postNotificationName:contactListNeedUpdateNoti object:nil];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:0.4];
            
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
    
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 4) {
        return 3;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2||indexPath.section == 3) {
        return 90;
    }else if  ( indexPath.section == 0) {
        if (_albumArray.count == 0) {
            return 0;
        }
        
        return 90;
    }
    
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        OthersAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.headerPicArray = _albumArray;
        NSLog(@"%@",cell.headerPicArray);
        return cell;
    }
    else if (indexPath.section == 1) {
        
        OtherUserBasicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicInfoCell" forIndexPath:indexPath];
        NSString *str = [NSString stringWithFormat:@"%@个",_model.guideCnt];
        cell.information.text = str;
        cell.information.font = [UIFont systemFontOfSize:14];
        cell.basicLabel.font = [UIFont systemFontOfSize:15];
//        cell.basicLabel.textColor = TEXT_COLOR_TITLE;
        cell.basicLabel.text = @"TA的旅行计划";
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else if (indexPath.section == 2) {
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zuji" forIndexPath:indexPath];
        cell.nameLabel.text = @"TA的足迹";
        cell.footPrint.textColor = TEXT_COLOR_TITLE;
        NSDictionary *country = _model.travels;
        NSInteger cityNumber = 0;
        NSMutableString *cityDesc = nil;
        NSArray *keys = [country allKeys];
        NSInteger countryNumber = keys.count;
        for (int i = 0; i < countryNumber; ++i) {
            NSArray *citys = [country objectForKey:[keys objectAtIndex:i]];
            cityNumber += citys.count;
            for (id city in citys) {
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
            cell.trajectory.text = @"0国 0个城市";
            cell.footPrint.text = @"未设置足迹";
        }
        
        
        return cell;
    }
    else if (indexPath.section == 3) {
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zuji" forIndexPath:indexPath];
        cell.nameLabel.text = @"签名";
        cell.imageJiantou.image = nil;
        cell.backgroundColor = [UIColor whiteColor];
        if (_model.signature == nil || [_model.signature isBlankString] || _model.signature.length == 0) {
            cell.footPrint.text = @"未设置签名";
        } else {
            cell.footPrint.text = _model.signature;
        }
        cell.footPrint.textColor = TEXT_COLOR_TITLE;
        cell.trajectory.text = @"";
        return cell;
    }
    else  {
        OtherUserBasicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicInfoCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.basicLabel.font = [UIFont systemFontOfSize:16];
            cell.basicLabel.text = @"基本信息";
            cell.information.text = @"";
        }else if (indexPath.row == 1){
            cell.basicLabel.font = [UIFont systemFontOfSize:14];
            cell.basicLabel.text = @"   年龄";
            
            NSDateFormatter *format2=[[NSDateFormatter alloc]init];
            [format2 setDateFormat:@"yyyy/MM/dd"];
            NSString *str2=_model.birthday;
            NSDate *date = [format2 dateFromString:str2];
            NSTimeInterval dateDiff = [date timeIntervalSinceNow];
            int age=trunc(dateDiff/(60*60*24))/365;
            age = -age;
            cell.information.font = [UIFont systemFontOfSize:14];
            if (_model.birthday == nil||[_model.birthday isBlankString] || _model.birthday.length == 0) {
                cell.information.text = @"未设置";
            }else {
            cell.information.text = [NSString stringWithFormat:@"%d",age];
            }
        }else {
            cell.basicLabel.font = [UIFont systemFontOfSize:14];
            cell.basicLabel.text = @"   居住在";
            if (_model.residence.length == 0 || [_model.residence isBlankString] || _model.residence == nil) {
                cell.information.text = @"未设置";
            }else {
            cell.information.text = _model.residence;
            }
            cell.information.font = [UIFont systemFontOfSize:14];
        }
        return cell;
    }

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        MyGuideListTableViewController *listCtl = [[MyGuideListTableViewController alloc]init];
        listCtl.isExpert = YES;
        listCtl.userId = _model.userId;
        [self.navigationController pushViewController:listCtl animated:YES];
    }else if (indexPath.section == 2){
        TraceViewController *ctl = [[TraceViewController alloc] init];
        NSDictionary *country = _model.travels;
        NSMutableArray *traces = [[NSMutableArray alloc] init];
        NSArray *keys = [country allKeys];
        SuperPoi *sp;
        for (id key in keys) {
            NSArray *citys = [country objectForKey:key];
            for (id city in citys) {
                sp = [SuperPoi new];
                sp.zhName = [city objectForKey:@"zhName"];
                sp.lat = [[[city valueForKeyPath:@"location.coordinates"] objectAtIndex:1] floatValue];
                sp.lng = [[[city valueForKeyPath:@"location.coordinates"] objectAtIndex:0] floatValue];
                [traces addObject:sp];
            }
        }
        
        ctl.citys = traces;
        [self.navigationController pushViewController:ctl animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - http method

/**
 *  邀请好友
 *
 *  @param helloStr
 */
- (void)requestAddContactWithHello:(NSString *)helloStr
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
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:_model.userId forKey:@"userId"];
    if ([helloStr stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        helloStr = [NSString stringWithFormat:@"Hi, 我是%@", accountManager.account.nickName];
    }
    [params safeSetObject:helloStr forKey:@"message"];
    
    __weak typeof(OtherUserInfoViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    [manager POST:API_REQUEST_ADD_CONTACT parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showHint:@"请求已发送，等待对方验证"];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:0.2];
        } else {
            [SVProgressHUD showHint:@"添加失败"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
    
}

- (void) loadUserProfile:(NSNumber *)userId {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", [AccountManager shareAccountManager].account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", API_USERINFO, userId];
    NSLog(@"%@",url);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSLog(@"%@",responseObject);
            [self parseUserProfileData:[responseObject objectForKey:@"result"]];
        } else {
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showHint:@"请求失败"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)loadUserAlbum
{
    TZProgressHUD *hud = [[TZProgressHUD alloc]init];
    __weak typeof(OtherUserInfoViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf content:64];
    AccountManager *account = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", account.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/albums", API_USERINFO, _userId];
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self paraseUserAlbum:[responseObject objectForKey:@"result"]];

            [_tableView reloadData];
        } else {
            [_tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_tableView reloadData];
    }];
}

- (void)paraseUserAlbum:(NSArray *)albumArray
{
    
    for (id album in albumArray) {
        [_albumArray addObject:[[AlbumImage alloc] initWithJson:album]];
    }
}

- (void)parseUserProfileData:(id )json
{
    _model = [[UserProfile alloc] initWithJsonObject:json];
    self.navigationItem.title = _model.name;
    [self createHeader];
    [self createFooterBar];
    TZProgressHUD *hud = [[TZProgressHUD alloc]init];
    [hud hideTZHUD];
    [_tableView reloadData];
}

@end
















