//
//  OtherUserInfoViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/5/16.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "OtherUserInfoViewController.h"
#import "PlansListTableViewController.h"
#import "HeaderCell.h"
#import "OtherUserBasicInfoCell.h"
#import "OthersAlbumCell.h"
#import "TraceViewController.h"
#import "ChatViewController.h"
#import "ChatSettingViewController.h"
#import "AccountModel.h"
#import "UIBarButtonItem+MJ.h"
#import "REFrostedViewController.h"
#import "ChatGroupSettingViewController.h"
#import "UIImage+resized.h"
@interface OtherUserInfoViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UIImageView *_headerView;
    BOOL _isMyFriend;
    NSMutableArray *_albumArray;
    UIView *_headerBgView;
    UIImageView *_avatarImageView;
    UIImageView *_avatarBg;
    UIImageView *_constellationView;
    UIImageView *_levelBg;
    UIImageView *_flagHeaderIV;
    UILabel *_levelLabel;
    UILabel *_nameLabel;
    UILabel *_idLabel;
    UILabel *_trackLabel;
    UILabel *_albumLabel;
    UILabel *_age;
    UILabel *_recidence;
    UILabel *_planeLabel;
}

@property (nonatomic, strong) FrendModel *userInfo;
@end

@implementation OtherUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _albumArray = [NSMutableArray array];
    AccountManager *accountManager = [AccountManager shareAccountManager];

    _isMyFriend = [accountManager frendIsMyContact:_userId];
    
    if (_isMyFriend) {
        UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        [moreBtn setImage:[UIImage imageNamed:@"account_icon_any_default"] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        [moreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    }
    [self setupTableHeaderView];
    [self createFooterBar];
    [self loadUserProfile:_userId];
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:_tableView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) setupTableHeaderView {
    CGFloat width = SCREEN_WIDTH;
    CGFloat height = SCREEN_HEIGHT;
    
    _headerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 924/3*height/736)];
    _headerBgView.backgroundColor = APP_PAGE_COLOR;
    _headerBgView.clipsToBounds = YES;


    CGFloat ah = 200*height/736;
    
    CGFloat avatarW = ah - 19 * height/736;
    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(107*width/414, 144/3*height/736, avatarW, avatarW)];
    _avatarImageView.clipsToBounds = YES;
    _avatarImageView.layer.cornerRadius = avatarW/2.0;
    _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_avatarImageView setImage:[UIImage imageNamed:@"ic_home_userentry_unlogin.png"]];
    [_headerBgView addSubview:_avatarImageView];
    
    _avatarBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ah, ah)];
    _avatarBg.center = _avatarImageView.center;
    _avatarBg.contentMode = UIViewContentModeScaleToFill;
    _avatarBg.clipsToBounds = YES;
    _avatarBg.image = [UIImage imageNamed:@"ic_home_avatar_border_unknown.png"];
    [_headerBgView addSubview:_avatarBg];
    
    _constellationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    _constellationView.center = CGPointMake(width/2.0 - 18, CGRectGetMaxY(_avatarBg.frame) - 5);
    _constellationView.contentMode = UIViewContentModeScaleAspectFit;
    _constellationView.image = [UIImage imageNamed:@"ic_home_user_constellation_shooter.png"];
    [_headerBgView addSubview:_constellationView];
    
    _levelBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 20)];
    _levelBg.center = CGPointMake(width/2.0 + 10, CGRectGetMaxY(_avatarBg.frame) - 5);
    _levelBg.contentMode = UIViewContentModeScaleAspectFit;
    _levelBg.image = [UIImage imageNamed:@"ic_home_level_bg_unknown.png"];
    [_headerBgView addSubview:_levelBg];
    
    _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 18)];
    _levelLabel.textColor = [UIColor whiteColor];
    _levelLabel.font = [UIFont systemFontOfSize:9];
    _levelLabel.text = @"LV0";
    _levelLabel.textAlignment = NSTextAlignmentCenter;
    [_levelBg addSubview:_levelLabel];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width/2, 44)];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, width/2, 18)];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont boldSystemFontOfSize:16];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.text = @"旅行派";
    [view addSubview:_nameLabel];
    
    _idLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, width/2, 12)];
    _idLabel.textColor = [UIColor whiteColor];
    _idLabel.font = [UIFont boldSystemFontOfSize:10];
    _idLabel.textAlignment = NSTextAlignmentCenter;
    _idLabel.text = @"";
    [view addSubview:_idLabel];
    
    _recidence = [[UILabel alloc]initWithFrame:CGRectMake(0, 584/3*height/736, 318/3*width/414, 15)];
    _recidence.textColor = TEXT_COLOR_TITLE;
    _recidence.textAlignment = NSTextAlignmentCenter;
    _recidence.font = [UIFont systemFontOfSize:12];
    [_headerBgView addSubview:_recidence];
    
    UILabel *recidenceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (584+78)/3*height/736, 318/3*width/414, 15)];
    recidenceLabel.text = @"地区";
    recidenceLabel.textAlignment = NSTextAlignmentCenter;
    recidenceLabel.font = [UIFont systemFontOfSize:11];
    recidenceLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    [_headerBgView addSubview:recidenceLabel];
    
    UIImageView *devideImage = [[UIImageView alloc]initWithFrame:CGRectMake((318/3*width/414 - 80)/2, (584+54)/3*height/736, 80, 1)];
    devideImage.image = [UIImage imageNamed:@"account_line_default"];
    [_headerBgView addSubview:devideImage];
    
    
    _age = [[UILabel alloc]initWithFrame:CGRectMake(922/3*width/414, 584/3*height/736, 318/3*width/414, 15)];
    _age.textColor = TEXT_COLOR_TITLE;
    _age.textAlignment = NSTextAlignmentCenter;
    _age.font = [UIFont systemFontOfSize:12];
    [_headerBgView addSubview:_age];
    
    UILabel *ageLabel = [[UILabel alloc]initWithFrame:CGRectMake(922/3*width/414, (584+78)/3*height/736, 318/3*width/414, 15)];
    ageLabel.text = @"年龄";
    ageLabel.textAlignment = NSTextAlignmentCenter;
    ageLabel.font = [UIFont systemFontOfSize:11];
    ageLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    [_headerBgView addSubview:ageLabel];
    
    UIImageView *devideImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(922/3*width/414 + 7, (584+54)/3*height/736, 80, 1)];
    devideImage2.image = [UIImage imageNamed:@"account_line_default"];
    [_headerBgView addSubview:devideImage2];

    
    [self.view addSubview:_headerBgView];
    
    self.navigationItem.titleView = view;
    CGFloat btnWidth = width/2-1;
    CGFloat btnHeight = (height - 64 - _headerBgView.bounds.size.height - 45)/2 ;
    UIButton *planeBtn = [[UIButton alloc]initWithFrame:CGRectMake(1, 924/3*height/736, btnWidth, btnHeight)];
    [planeBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [planeBtn setBackgroundImage:[UIImage resizedImageWithName:@"account_bg_button_normal"] forState:UIControlStateNormal];
    [planeBtn setBackgroundImage:[UIImage resizedImageWithName:@"account_bg_button_selected"] forState:UIControlStateHighlighted];
    [planeBtn addTarget:self action:@selector(seeOthersPlan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:planeBtn];
    
//    CGFloat YY = 165/3 * height/736;
    CGFloat YY = btnHeight/2 - 20 - 5;
    
    _planeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, YY, btnWidth, 20)];
    _planeLabel.font = [UIFont systemFontOfSize:20* height/736];
    _planeLabel.textColor = TEXT_COLOR_TITLE;
    _planeLabel.textAlignment = NSTextAlignmentCenter;
    [planeBtn addSubview:_planeLabel];
    UILabel *planeLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, YY+31* height/736, btnWidth, 20)];
    planeLabel2.font = [UIFont systemFontOfSize:16* height/736];
    planeLabel2.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    planeLabel2.textAlignment = NSTextAlignmentCenter;
    planeLabel2.text = @"计划";
    [planeBtn addSubview:planeLabel2];
    
    UIButton *trackBtn = [[UIButton alloc]initWithFrame:CGRectMake(width/2 + 2, 924/3*height/736, width/2-1, btnHeight)];
    [trackBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [trackBtn setBackgroundImage:[UIImage resizedImageWithName:@"account_bg_button_normal"] forState:UIControlStateNormal];
    [trackBtn setBackgroundImage:[UIImage resizedImageWithName:@"account_bg_button_selected"] forState:UIControlStateHighlighted];
    [trackBtn addTarget:self action:@selector(visitTracks) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:trackBtn];
    
    _trackLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, YY, btnWidth, 20)];
    _trackLabel.font = [UIFont systemFontOfSize:20* height/736];
    _trackLabel.textColor = TEXT_COLOR_TITLE;
    _trackLabel.textAlignment = NSTextAlignmentCenter;
    [trackBtn addSubview:_trackLabel];
    UILabel *trackLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, YY+31* height/736, btnWidth, 20)];
    trackLabel2.font = [UIFont systemFontOfSize:16* height/736];
    trackLabel2.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    trackLabel2.textAlignment = NSTextAlignmentCenter;
    trackLabel2.text = @"足迹";
    [trackBtn addSubview:trackLabel2];
    
    UIButton *albumBtn = [[UIButton alloc]initWithFrame:CGRectMake(1, 924/3*height/736 + btnHeight, width/2-1, btnHeight)];
    [albumBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [albumBtn setBackgroundImage:[UIImage resizedImageWithName:@"account_bg_button_normal"] forState:UIControlStateNormal];
    [albumBtn setBackgroundImage:[UIImage resizedImageWithName:@"account_bg_button_selected"] forState:UIControlStateHighlighted];
    [self.view addSubview:albumBtn];
    
    _albumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, YY, btnWidth, 20)];
    _albumLabel.font = [UIFont systemFontOfSize:20* height/736];
    _albumLabel.textColor = TEXT_COLOR_TITLE;
    _albumLabel.textAlignment = NSTextAlignmentCenter;
    _albumLabel.text = [NSString stringWithFormat:@"%lu",_albumArray.count];
    [albumBtn addSubview:_albumLabel];
    UILabel *albumLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, YY+31* height/736, btnWidth, 20)];
    albumLabel2.font = [UIFont systemFontOfSize:16* height/736];
    albumLabel2.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    albumLabel2.textAlignment = NSTextAlignmentCenter;
    albumLabel2.text = @"相册";
    [albumBtn addSubview:albumLabel2];
    
    UIButton *travelNote = [[UIButton alloc]initWithFrame:CGRectMake(width/2+2, 924/3*height/736 + btnHeight, width/2-1, btnHeight)];
    [travelNote setBackgroundImage:[UIImage resizedImageWithName:@"account_bg_button_normal"] forState:UIControlStateNormal];
    [travelNote setBackgroundImage:[UIImage resizedImageWithName:@"account_bg_button_selected"] forState:UIControlStateHighlighted];
    [travelNote setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [self.view addSubview:travelNote];
    
    UILabel *travelNoteLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, YY, btnWidth, 20)];
    travelNoteLabel.font = [UIFont systemFontOfSize:20* height/736];
    travelNoteLabel.textColor = TEXT_COLOR_TITLE;
    travelNoteLabel.textAlignment = NSTextAlignmentCenter;
    [travelNote addSubview:travelNoteLabel];
    UILabel *travelNoteLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, YY+31* height/736, btnWidth, 20)];
    travelNoteLabel2.font = [UIFont systemFontOfSize:16* height/736];
    travelNoteLabel2.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    travelNoteLabel2.textAlignment = NSTextAlignmentCenter;
    travelNoteLabel2.text = @"游记";
    [travelNote addSubview:travelNoteLabel2];
}
- (void)updateUserInfo
{
    UILabel *signatureLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 924/3*SCREEN_HEIGHT/736 - 27, SCREEN_WIDTH, 13)];
    signatureLabel.text = _userInfo.signature;
    signatureLabel.textAlignment = NSTextAlignmentCenter;
    signatureLabel.textColor = APP_THEME_COLOR;
    [_headerBgView addSubview:signatureLabel];
    
    NSDateFormatter *format2=[[NSDateFormatter alloc]init];
    [format2 setDateFormat:@"yyyy/MM/dd"];
    NSString *str2=_userInfo.birthday;
    NSDate *date = [format2 dateFromString:str2];
    NSTimeInterval dateDiff = [date timeIntervalSinceNow];
    int age=trunc(dateDiff/(60*60*24))/365;
    age = -age;
    if (_userInfo.birthday == nil||[_userInfo.birthday isBlankString] || _userInfo.birthday.length == 0) {
        _age.text = @"未设置";
    }else {
        _age.text = [NSString stringWithFormat:@"%d",age];
    }
    if (_userInfo.residence == nil||[_userInfo.residence isBlankString] || _userInfo.residence.length == 0) {
        _recidence.text = @"未设置";
    }else {
        _recidence.text = _userInfo.residence;
    }
    
    NSInteger cityNumber = 0;
    NSMutableString *cityDesc = [[NSMutableString alloc] init];
    for (AreaDestination *area in _userInfo.tracks) {
        for (CityDestinationPoi *poi in area.cities) {
            [cityDesc appendString:[NSString stringWithFormat:@"%@ ", poi.zhName]];
            cityNumber++;
        }
    }
    _trackLabel.text = [NSString stringWithFormat:@"%ld国 %ld城", (long)_userInfo.tracks.count, (long)cityNumber];
    NSString *guideCtn = [NSString stringWithFormat:@"%lu",_userInfo.guideCount];
    _planeLabel.text = guideCtn;
    
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_userInfo.avatarSmall] placeholderImage:[UIImage imageNamed:@"ic_home_avatar_unknown.png"]];
    _nameLabel.text = _userInfo.nickName;
    NSString *userIdStr = [NSString stringWithFormat:@"%lu",_userInfo.userId];
    _idLabel.text = userIdStr;
    if ([_userInfo.sex isEqualToString:@"M" ]) {
        _avatarBg.image = [UIImage imageNamed:@"ic_home_avatar_border_boy.png"];
        _levelBg.image = [UIImage imageNamed:@"ic_home_level_bg_boy.png"];
        _flagHeaderIV.image = [UIImage imageNamed:@"ic_home_header_boy.png"];
    } else if ([_userInfo.sex isEqualToString: @"F"]) {
        _avatarBg.image = [UIImage imageNamed:@"ic_home_avatar_border_girl.png"];
        _levelBg.image = [UIImage imageNamed:@"ic_home_level_bg_girl.png"];
        _flagHeaderIV.image = [UIImage imageNamed:@"ic_home_header_girl.png"];
    } else {
        _avatarBg.image = [UIImage imageNamed:@"ic_home_avatar_border_unknown.png"];
        _flagHeaderIV.image = [UIImage imageNamed:@"ic_home_header_unlogin.png"];
        _levelBg.image = [UIImage imageNamed:@"ic_home_level_bg_unknown.png"];
    }

}

-(void)createFooterBar
{
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-45, CGRectGetWidth(self.view.bounds), 45)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:toolBar];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    UIButton *beginTalk = [[UIButton alloc]initWithFrame:CGRectMake(1, 0, CGRectGetWidth(self.view.bounds)/2-1, 45)];
    [beginTalk setTitle:@"开始聊天" forState:UIControlStateNormal];
    [beginTalk setBackgroundImage:[UIImage imageNamed:@"account_bg_button_normal"] forState:UIControlStateNormal];
    [beginTalk setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [beginTalk setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [beginTalk setImage:[UIImage imageNamed:@"ic_home_normal"] forState:UIControlStateNormal];
    beginTalk.titleLabel.font = [UIFont systemFontOfSize:16];
    [beginTalk addTarget:self action:@selector(talkToFriend) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:beginTalk];
    UIButton *addFriend = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2+1, 0, CGRectGetWidth(self.view.bounds)/2-1, 45)];
    
    addFriend.titleLabel.font = [UIFont systemFontOfSize:16];
    [addFriend setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [addFriend setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [addFriend setBackgroundImage:[UIImage imageNamed:@"account_bg_button_normal"] forState:UIControlStateNormal];
    [addFriend setBackgroundImage:[UIImage imageNamed:@"account_bg_button_selected"] forState:UIControlStateHighlighted];
    [addFriend setImage:[UIImage imageNamed:@"account_labbar_icon_follow_selected"] forState:UIControlStateNormal];
    [toolBar addSubview:addFriend];
    if ([accountManager frendIsMyContact:_userId]) {
        [addFriend setTitle:@"备注" forState:UIControlStateNormal];
        [addFriend addTarget:self action:@selector(remarkFriend) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [addFriend setTitle:@"加为好友" forState:UIControlStateNormal];
        [addFriend addTarget:self action:@selector(addToFriend) forControlEvents:UIControlEventTouchUpInside];

    }
    

}

#pragma mark - IBAction

- (void)addToFriend {
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
- (void)remarkFriend
{
//    AccountManager *manager = [AccountManager shareAccountManager];
//    [manager asyncChangeRemark:<#(NSString *)#> withUserId:_userInfo._userId completion:^(BOOL isSuccess) {
//        
//    }];
}
- (void)talkToFriend {
    [self pushChatViewController];
}

- (void)pushChatViewController
{
    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:_userId chatType:IMChatTypeIMChatSingleType];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:chatController];
    
    UIViewController *menuViewController = nil;
   
    menuViewController = [[ChatSettingViewController alloc] init];
    ((ChatSettingViewController *)menuViewController).chatterId = _userId;
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:navi menuViewController:menuViewController];
    frostedViewController.hidesBottomBarWhenPushed = YES;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    frostedViewController.resumeNavigationBar = NO;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    [self.navigationController pushViewController:frostedViewController animated:YES];
    frostedViewController.navigationItem.title = _userInfo.nickName;
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
    AccountManager *accountManager = [AccountManager shareAccountManager];

    FrendManager *frendManager = [FrendManager shareInstance];
    __weak typeof(OtherUserInfoViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];

    [frendManager asyncRemoveContactWithFrend:_userInfo completion:^(BOOL isSuccess, NSInteger errorCode) {
        [hud hideTZHUD];

        if (isSuccess) {
            [accountManager removeContact:_userInfo];
            [SVProgressHUD showHint:@"已删除～"];
            [[NSNotificationCenter defaultCenter] postNotificationName:contactListNeedUpdateNoti object:nil];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:0.4];
            
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
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
        
        
        cell.headerPicArray = _albumArray;
        NSLog(@"%@",cell.headerPicArray);
        return cell;
    }
    else if (indexPath.section == 1) {
        
        OtherUserBasicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicInfoCell" forIndexPath:indexPath];
        cell.information.font = [UIFont systemFontOfSize:14];
        cell.basicLabel.font = [UIFont systemFontOfSize:15];
        cell.basicLabel.text = @"TA的旅行计划";
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else if (indexPath.section == 2) {
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zuji" forIndexPath:indexPath];
        cell.nameLabel.text = @"TA的足迹";
        cell.footPrint.textColor = TEXT_COLOR_TITLE;
        NSInteger cityNumber = 0;
        NSMutableString *cityDesc = [[NSMutableString alloc] init];
        for (AreaDestination *area in _userInfo.tracks) {
            for (CityDestinationPoi *poi in area.cities) {
                [cityDesc appendString:[NSString stringWithFormat:@"%@ ", poi.zhName]];
                cityNumber++;
            }
        }
        
        if (_userInfo.tracks.count > 0) {
            cell.trajectory.text = [NSString stringWithFormat:@"%ld国 %ld个城市", (long)_userInfo.tracks.count, (long)cityNumber];
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
        if (_userInfo.signature == nil || [_userInfo.signature isBlankString] || _userInfo.signature.length == 0) {
            cell.footPrint.text = @"未设置签名";
        } else {
            cell.footPrint.text = _userInfo.signature;
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
            NSString *str2=_userInfo.birthday;
            NSDate *date = [format2 dateFromString:str2];
            NSTimeInterval dateDiff = [date timeIntervalSinceNow];
            int age=trunc(dateDiff/(60*60*24))/365;
            age = -age;
            cell.information.font = [UIFont systemFontOfSize:14];
            if (_userInfo.birthday == nil||[_userInfo.birthday isBlankString] || _userInfo.birthday.length == 0) {
                cell.information.text = @"未设置";
            }else {
            cell.information.text = [NSString stringWithFormat:@"%d",age];
            }
        }else {
            cell.basicLabel.font = [UIFont systemFontOfSize:14];
            cell.basicLabel.text = @"   现住地";
            if (_userInfo.residence.length == 0 || [_userInfo.residence isBlankString] || _userInfo.residence == nil) {
                cell.information.text = @"未设置";
            }else {
            cell.information.text = _userInfo.residence;
            }
            cell.information.font = [UIFont systemFontOfSize:14];
        }
        return cell;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        PlansListTableViewController *listCtl = [[PlansListTableViewController alloc]initWithUserId:_userInfo.userId];
        [self.navigationController pushViewController:listCtl animated:YES];
        
    } else if (indexPath.section == 2){
        TraceViewController *ctl = [[TraceViewController alloc] init];
        NSMutableArray *tracks = [[NSMutableArray alloc] init];
        for (AreaDestination *area in _userInfo.tracks) {
            for (CityDestinationPoi *poi in area.cities) {
                [tracks addObject:poi];
            }
        }
        ctl.citys = tracks;
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

    FrendManager *frendManager = [FrendManager shareInstance];
    if ([helloStr stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        helloStr = [NSString stringWithFormat:@"Hi, 我是%@", accountManager.account.nickName];
    }
    __weak typeof(OtherUserInfoViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    [frendManager asyncRequestAddContactWithUserId:_userId helloStr:helloStr completion:^(BOOL isSuccess, NSInteger errorCode) {
        [hud hideTZHUD];
        if (isSuccess) {
            [SVProgressHUD showHint:@"请求已发送，等待对方验证"];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:0.2];
        } else {
            [SVProgressHUD showHint:@"添加失败"];
        }
        
    }];
}

- (void)loadUserProfile:(NSInteger)userId {
    
    FrendManager *frendManager = [[FrendManager alloc] init];
    [frendManager asyncGetFrendInfoFromServer:userId completion:^(BOOL isSuccess, NSInteger errorCode, FrendModel * __nonnull frend) {
        if (isSuccess) {
            _userInfo = frend;
//            [self createHeader];
//            [self createFooterBar];
            [self loadUserAlbum];
            [self updateUserInfo];
        } else {
            [SVProgressHUD showHint:@"请求失败"];
        }
    }];
}

- (void)loadUserAlbum
{
    AccountManager *account = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", account.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld/albums", API_USERINFO, (long)_userId];
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self paraseUserAlbum:[responseObject objectForKey:@"result"]];
//            [_tableView reloadData];
        } else {
//            [_tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [_tableView reloadData];
    }];
}

- (void)paraseUserAlbum:(NSArray *)albumArray
{
    for (id album in albumArray) {
        [_albumArray addObject:[[AlbumImage alloc] initWithJson:album]];
    }
    _userInfo.userAlbum = _albumArray;
    _albumLabel.text = [NSString stringWithFormat:@"%lu",_albumArray.count];
}

#pragma mark - buttonMethod
- (void)visitTracks
{
    TraceViewController *ctl = [[TraceViewController alloc] init];
    NSMutableArray *tracks = [[NSMutableArray alloc] init];
    for (AreaDestination *area in _userInfo.tracks) {
        for (CityDestinationPoi *poi in area.cities) {
            [tracks addObject:poi];
        }
    }
    ctl.citys = tracks;
    [self.navigationController pushViewController:ctl animated:YES];

}
- (void)seeOthersPlan
{
    PlansListTableViewController *listCtl = [[PlansListTableViewController alloc]initWithUserId:_userInfo.userId];
    [self.navigationController pushViewController:listCtl animated:YES];
}
@end
















