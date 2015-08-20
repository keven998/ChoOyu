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
#import "ChatViewController.h"
#import "ChatSettingViewController.h"
#import "AccountModel.h"
#import "UIBarButtonItem+MJ.h"
#import "REFrostedViewController.h"
#import "ChatGroupSettingViewController.h"
#import "UIImage+resized.h"
#import "ChatListViewController.h"
#import "MWPhotoBrowser.h"
#import "UserAlbumViewController.h"
#import "BaseTextSettingViewController.h"
#import "FootPrintViewController.h"
#import "CMPopTipView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "LoginViewController.h"
#import "TZNavigationViewController.h"

@interface OtherUserInfoViewController ()<UIActionSheetDelegate> {
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
    FrendModel *_userInfo;
    UIButton *_beginTalk;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FrendModel *userInfo;
@property (nonatomic, strong) UIButton *addFriendBtn;

@end

@implementation OtherUserInfoViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kWindowWidth, self.view.bounds.size.height - 45)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    _albumArray = [NSMutableArray array];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    _isMyFriend = [accountManager frendIsMyContact:_userId];
    
    UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    [moreBtn setImage:[UIImage imageNamed:@"account_icon_any_default"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
   
    [self setupTableHeaderView];
    [self createFooterBar];
    [self loadUserProfile:_userId];
    self.view.backgroundColor = APP_PAGE_COLOR;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_user_profile"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_user_profile"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL isNotShouldShowTipsView = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kShowExpertTipsView"] boolValue];
    if (!isNotShouldShowTipsView && _shouldShowExpertTipsView) {
        [self showExpertTipsViewWithView:_beginTalk];
    }
}

#pragma mark - privateMethod
- (void) setupTableHeaderView {
    CGFloat width = kWindowWidth;
    CGFloat height = kWindowHeight;
    
    _headerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 831/3*height/736)];
    _headerBgView.backgroundColor = APP_PAGE_COLOR;
    _headerBgView.clipsToBounds = YES;
    
    CGFloat ah = 200*height/736;
    
    CGFloat avatarW = ah - 19 * height/736;
    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, avatarW, avatarW)];
    _avatarImageView.center = CGPointMake(_headerBgView.center.x, _headerBgView.center.y + 9 * height/736);
    _avatarImageView.clipsToBounds = YES;
    _avatarImageView.layer.cornerRadius = avatarW/2.0;
    _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarImageView.userInteractionEnabled = YES;
    [_avatarImageView setImage:[UIImage imageNamed:@"ic_home_avatar_unknown.png"]];
    [_headerBgView addSubview:_avatarImageView];
    
    UITapGestureRecognizer * tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
    [_avatarImageView addGestureRecognizer:tapAvatar];
    
    _avatarBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ah, ah)];
    _avatarBg.center = _avatarImageView.center;
    _avatarBg.contentMode = UIViewContentModeScaleToFill;
    _avatarBg.clipsToBounds = YES;
    _avatarBg.image = [UIImage imageNamed:@"ic_home_avatar_border_unknown.png"];
    [_headerBgView addSubview:_avatarBg];
    
    _levelBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 20)];
    _levelBg.center = CGPointMake(width/2.0 + 10, CGRectGetMaxY(_avatarBg.frame) - 5);
    _levelBg.contentMode = UIViewContentModeScaleAspectFit;
    _levelBg.image = [UIImage imageNamed:@"ic_home_level_bg_unknown.png"];
    [_headerBgView addSubview:_levelBg];
    
    _constellationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    _constellationView.center = CGPointMake(width/2.0 - 18, CGRectGetMaxY(_avatarBg.frame) - 5);
    _constellationView.contentMode = UIViewContentModeScaleAspectFit;
    _constellationView.image = [UIImage imageNamed:[FrendModel bigCostellationImageNameWithBirthday:_userInfo.birthday]];

    [_headerBgView addSubview:_constellationView];
    
    _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 18)];
    _levelLabel.textColor = [UIColor whiteColor];
    _levelLabel.font = [UIFont systemFontOfSize:9];
    _levelLabel.text = [NSString stringWithFormat:@"LV%ld", (long)_userInfo.level];
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
    _idLabel.text = @"ID：";
    [view addSubview:_idLabel];
    
    UILabel *recidenceLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(_constellationView.frame) - 32, CGRectGetMinX(_avatarBg.frame) - 15, 14)];
    recidenceLabel.text = @"现居地";
    recidenceLabel.textAlignment = NSTextAlignmentCenter;
    recidenceLabel.font = [UIFont systemFontOfSize:10];
    recidenceLabel.textColor = COLOR_TEXT_III;
    [_headerBgView addSubview:recidenceLabel];
    
    UIImageView *devideImage = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(recidenceLabel.frame), CGRectGetMinY(recidenceLabel.frame)-2, CGRectGetWidth(recidenceLabel.frame), 1)];
    devideImage.contentMode = UIViewContentModeScaleToFill;
    devideImage.image = [UIImage imageNamed:@"account_line_default"];
    [_headerBgView addSubview:devideImage];
    
    _recidence = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(recidenceLabel.frame), CGRectGetMinY(recidenceLabel.frame)-19, CGRectGetWidth(recidenceLabel.frame), 16)];
    _recidence.textColor = COLOR_TEXT_I;
    _recidence.textAlignment = NSTextAlignmentCenter;
    _recidence.font = [UIFont systemFontOfSize:12];
    [_headerBgView addSubview:_recidence];
    
    
    UILabel *ageLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_avatarBg.frame), CGRectGetMaxY(_constellationView.frame) - 32, width - CGRectGetMaxX(_avatarBg.frame) - 15, 14)];
    ageLabel.text = @"Age";
    ageLabel.textAlignment = NSTextAlignmentCenter;
    ageLabel.font = [UIFont systemFontOfSize:10];
    ageLabel.textColor = COLOR_TEXT_III;
    [_headerBgView addSubview:ageLabel];
    
    UIImageView *devideImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(ageLabel.frame), CGRectGetMinY(ageLabel.frame)-2, CGRectGetWidth(ageLabel.frame), 1)];
    devideImage2.contentMode = UIViewContentModeScaleToFill;
    devideImage2.image = [UIImage imageNamed:@"account_line_default"];
    [_headerBgView addSubview:devideImage2];
    
    _age = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(ageLabel.frame), CGRectGetMinY(ageLabel.frame)-19, CGRectGetWidth(ageLabel.frame), 16)];
    _age.textColor = COLOR_TEXT_I;
    _age.textAlignment = NSTextAlignmentCenter;
    _age.font = [UIFont systemFontOfSize:12];
    [_headerBgView addSubview:_age];
    
    [_scrollView addSubview:_headerBgView];
    
    self.navigationItem.titleView = view;
    CGFloat btnWidth = width/2;
    CGFloat btnHeight;
    //    if (kWindowHeight == 480) {
    //        btnHeight = (height - 64 - _headerBgView.bounds.size.height - 45)/2 ;
    //    } else {
    btnHeight = btnWidth * 471/615;
    //    }
    
    UIButton *planeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 831/3*height/736, btnWidth-2, btnHeight-4)];
    [planeBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [planeBtn setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateHighlighted];
    [planeBtn addTarget:self action:@selector(seeOthersPlan) forControlEvents:UIControlEventTouchUpInside];
    planeBtn.layer.shadowColor = COLOR_LINE.CGColor;
    planeBtn.layer.shadowOffset = CGSizeMake(1, 1);
    planeBtn.layer.shadowRadius = 2;
    planeBtn.layer.shadowOpacity = 1;
    [_scrollView addSubview:planeBtn];
    CGFloat YY = btnHeight/2 - 20 - 5;
    _planeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, YY, btnWidth, 20)];
    _planeLabel.font = [UIFont systemFontOfSize:16];
    _planeLabel.textColor = COLOR_TEXT_I;
    _planeLabel.textAlignment = NSTextAlignmentCenter;
    [planeBtn addSubview:_planeLabel];
    UILabel *planeLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, YY+31* height/736, btnWidth, 20)];
    planeLabel2.font = [UIFont systemFontOfSize:13];
    planeLabel2.textColor = COLOR_TEXT_II;
    planeLabel2.textAlignment = NSTextAlignmentCenter;
    planeLabel2.text = @"计划";
    [planeBtn addSubview:planeLabel2];
    
    UIButton *trackBtn = [[UIButton alloc]initWithFrame:CGRectMake(btnWidth+2, 831/3*height/736, btnWidth-2, btnHeight - 4)];
    [trackBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [trackBtn setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateHighlighted];
    trackBtn.layer.shadowColor = COLOR_LINE.CGColor;
    trackBtn.layer.shadowOffset = CGSizeMake(-1, 1);
    trackBtn.layer.shadowRadius = 2;
    trackBtn.layer.shadowOpacity = 1;
    [trackBtn addTarget:self action:@selector(visitTracks) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:trackBtn];
    _trackLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, YY, btnWidth, 20)];
    _trackLabel.font = [UIFont systemFontOfSize:16];
    _trackLabel.textColor = COLOR_TEXT_I;
    _trackLabel.textAlignment = NSTextAlignmentCenter;
    [trackBtn addSubview:_trackLabel];
    UILabel *trackLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, YY+31* height/736, btnWidth, 20)];
    trackLabel2.font = [UIFont systemFontOfSize:13];
    trackLabel2.textColor = COLOR_TEXT_II;
    trackLabel2.textAlignment = NSTextAlignmentCenter;
    trackLabel2.text = @"足迹";
    [trackBtn addSubview:trackLabel2];
    
    UIButton *albumBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 831/3*height/736 + btnHeight, btnWidth-2, btnHeight-4)];
    [albumBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [albumBtn setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateHighlighted];
    [albumBtn addTarget:self action:@selector(viewUserPhotoAlbum) forControlEvents:UIControlEventTouchUpInside];
    albumBtn.layer.shadowColor = COLOR_LINE.CGColor;
    albumBtn.layer.shadowOffset = CGSizeMake(1, -1);
    albumBtn.layer.shadowRadius = 2;
    albumBtn.layer.shadowOpacity = 1;
    [_scrollView addSubview:albumBtn];
    _albumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, YY, btnWidth, 20)];
    _albumLabel.font = [UIFont systemFontOfSize:16];
    _albumLabel.textColor = COLOR_TEXT_I;
    _albumLabel.textAlignment = NSTextAlignmentCenter;
    _albumLabel.text = [NSString stringWithFormat:@"%zd张",_albumArray.count];
    [albumBtn addSubview:_albumLabel];
    UILabel *albumLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, YY+31* height/736, btnWidth, 20)];
    albumLabel2.font = [UIFont systemFontOfSize:13];
    albumLabel2.textColor = COLOR_TEXT_II;
    albumLabel2.textAlignment = NSTextAlignmentCenter;
    albumLabel2.text = @"相册";
    [albumBtn addSubview:albumLabel2];
    
    UIButton *travelNote = [[UIButton alloc]initWithFrame:CGRectMake(btnWidth+2, 831/3*height/736 + btnHeight, btnWidth-2, btnHeight-4)];
    [travelNote setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [travelNote setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateHighlighted];
    travelNote.layer.shadowColor = COLOR_LINE.CGColor;
    travelNote.layer.shadowOffset = CGSizeMake(-1, -1);
    travelNote.layer.shadowRadius = 2;
    travelNote.layer.shadowOpacity = 1;
    [travelNote setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    
    // 游记功能暂未实现,此时隐藏游记按钮
//    [_scrollView addSubview:travelNote];
    UILabel *travelNoteLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, YY, btnWidth, 20)];
    travelNoteLabel.font = [UIFont systemFontOfSize:20* height/736];
    travelNoteLabel.textColor = COLOR_TEXT_I;
    travelNoteLabel.textAlignment = NSTextAlignmentCenter;
    
    [travelNote addSubview:travelNoteLabel];
    UILabel *travelNoteLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, YY+31* height/736, btnWidth, 20)];
    travelNoteLabel2.font = [UIFont systemFontOfSize:16* height/736];
    travelNoteLabel2.textColor = COLOR_TEXT_II;
    travelNoteLabel2.textAlignment = NSTextAlignmentCenter;
    travelNoteLabel2.text = @"游记";
    
    [travelNote addSubview:travelNoteLabel2];
    _scrollView.contentSize = CGSizeMake(width, btnWidth * 2 + _headerBgView.bounds.size.height);
}

#pragma mark - 实现单击手势的事件
- (void)tapAvatar:(UIGestureRecognizer *)tap{
    NSLog(@"点击了头像");
    
        // 1.封装图片数据
        NSMutableArray *photos = [NSMutableArray array];
        
        // 替换为中等尺寸图片
        MJPhoto *photo = [[MJPhoto alloc] init];
        //    photo.url = [imageArray objectAtIndex:i]; // 图片路径
        
        photo.url = self.userInfo.avatar;
        photo.srcImageView = (UIImageView *)tap.view; // 来源于哪个UIImageView
        [photos addObject:photo];
        
        // 2.显示相册
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        [browser show];
    
}


- (void)updateUserInfo
{
    UILabel *signatureLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 924/3*kWindowHeight/736 - 27, kWindowWidth, 13)];
    signatureLabel.text = _userInfo.signature;
    signatureLabel.textAlignment = NSTextAlignmentCenter;
    signatureLabel.textColor = APP_THEME_COLOR;
    //    [_headerBgView addSubview:signatureLabel];
    
    NSDateFormatter *format2=[[NSDateFormatter alloc]init];
    [format2 setDateFormat:@"yyyy/MM/dd"];
    NSString *str2=_userInfo.birthday;
    NSDate *date = [format2 dateFromString:str2];
    NSTimeInterval dateDiff = [date timeIntervalSinceNow];
    int age=trunc(dateDiff/(60*60*24))/365;
    age = -age;
    if (_userInfo.birthday == nil||[_userInfo.birthday isBlankString]) {
        _age.text = @"未设置";
    } else {
        _age.text = [NSString stringWithFormat:@"%d",age];
    }
    if (_userInfo.residence == nil||[_userInfo.residence isBlankString]) {
        _recidence.text = @"未设置";
    } else {
        _recidence.text = _userInfo.residence;
    }

    _constellationView.image = [UIImage imageNamed:[FrendModel bigCostellationImageNameWithBirthday:_userInfo.birthday]];
    
    _trackLabel.text = _userInfo.footprintDescription;
    
    NSLog(@"%@",_userInfo.footprintDescription);
    
    NSString *guideCtn = [NSString stringWithFormat:@"%zd条",_userInfo.guideCount];
    _planeLabel.text = guideCtn;
    
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_userInfo.avatarSmall] placeholderImage:[UIImage imageNamed:@"ic_home_avatar_unknown.png"]];
    if ([_userInfo.memo isBlankString]) {
        _nameLabel.text = _userInfo.nickName;
    } else {
        _nameLabel.text = [NSString stringWithFormat:@"(%@)%@", _userInfo.memo, _userInfo.nickName];
    }
    NSString *userIdStr = [NSString stringWithFormat:@"ID：%zd",_userInfo.userId];
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
    UIImageView *barView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, CGRectGetWidth(self.view.bounds), 49)];
    barView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [barView setImage:[UIImage imageNamed:@"account_button_default.png"]];
    barView.contentMode = UIViewContentModeScaleToFill;
    barView.userInteractionEnabled = YES;
    [self.view addSubview:barView];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    _beginTalk = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds)/2, 48)];
    [_beginTalk setTitle:@"发送消息" forState:UIControlStateNormal];
    [_beginTalk setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    [_beginTalk setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [_beginTalk setImage:[UIImage imageNamed:@"ic_home_normal.png"] forState:UIControlStateNormal];
    [_beginTalk setBackgroundImage:[UIImage imageNamed:@"account_button_selected.png"] forState:UIControlStateHighlighted];
    _beginTalk.titleLabel.font = [UIFont systemFontOfSize:13];
    [_beginTalk setImageEdgeInsets:UIEdgeInsetsMake(3, -5, 0, 0)];
    [_beginTalk setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, -5)];
    [_beginTalk addTarget:self action:@selector(talkToFriend) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:_beginTalk];
    _addFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2, 0, CGRectGetWidth(self.view.bounds)/2, 48)];
    
    _addFriendBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_addFriendBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [_addFriendBtn setImage:[UIImage imageNamed:@"account_labbar_icon_follow_default.png"] forState:UIControlStateNormal];
    [_addFriendBtn setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted];
    [_addFriendBtn setBackgroundImage:[UIImage imageNamed:@"account_button_selected.png"] forState:UIControlStateHighlighted];
    [_addFriendBtn setImageEdgeInsets:UIEdgeInsetsMake(3, -5, 0, 0)];
    [_addFriendBtn setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, -5)];
    [barView addSubview:_addFriendBtn];
    if ([accountManager frendIsMyContact:_userId]) {
        [_addFriendBtn setTitle:@"修改备注" forState:UIControlStateNormal];
        [_addFriendBtn addTarget:self action:@selector(remarkFriend) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_addFriendBtn setTitle:@"加为朋友" forState:UIControlStateNormal];
        [_addFriendBtn addTarget:self action:@selector(addToFriend) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

#pragma mark - IBAction

- (void)addToFriend {
    
    if ([AccountManager shareAccountManager].isLogin) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"朋友验证" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *nameTextField = [alert textFieldAtIndex:0];
        AccountManager *accountManager = [AccountManager shareAccountManager];
        nameTextField.text = [NSString stringWithFormat:@"Hi, 我是%@", accountManager.account.nickName];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self requestAddContactWithHello:nameTextField.text];
            }
        }];
    } else {
        [self userLogin];
    }
}

- (void)viewUserPhotoAlbum
{
    [MobClick event:@"button_item_album"];
    UserAlbumViewController *ctl = [[UserAlbumViewController alloc] initWithNibName:@"UserAlbumViewController" bundle:nil];
    ctl.albumArray = [self.userInfo.userAlbum mutableCopy];
    [self.navigationController pushViewController:ctl animated:YES];
}

/**
 *  修改好友备注
 */
- (void)remarkFriend
{
    BaseTextSettingViewController *bsvc = [[BaseTextSettingViewController alloc] init];
    bsvc.navTitle = @"修改备注";
    if (_userInfo.memo.length > 0) {
        bsvc.content = _userInfo.memo;
    } else {
        bsvc.content = _userInfo.nickName;
    }
    bsvc.acceptEmptyContent = NO;
    bsvc.saveEdition = ^(NSString *editText, saveComplteBlock(completed)) {
        [self confirmChange:editText withContacts:_userInfo success:completed];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:bsvc] animated:YES completion:nil];
}

- (void)confirmChange:(NSString *)text withContacts:(FrendModel *)contact success:(saveComplteBlock)completed
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    contact.memo = text;
    completed(YES);
    [accountManager asyncChangeRemark:text withUserId:contact.userId completion:^(BOOL isSuccess) {
        if (isSuccess) {
        } else {
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)talkToFriend {
    
    if ([AccountManager shareAccountManager].isLogin) {
         [self pushChatViewController];
    } else {
        [self userLogin];
    }
}

#pragma mark - IBAction Methods

- (void)userLogin
{
    if ([AccountManager shareAccountManager].isLogin) {
        return;
    }
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
}

- (void)pushChatViewController
{
    IMClientManager *manager = [IMClientManager shareInstance];
    ChatConversation *conversation = [manager.conversationManager getConversationWithChatterId:_userId chatType:IMChatTypeIMChatSingleType];
    [manager.conversationManager addConversation: conversation];
    
    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:_userId chatType:IMChatTypeIMChatSingleType];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:chatController];
    chatController.chatterName = _userInfo.nickName;
    
    ChatSettingViewController *menuViewController = [[ChatSettingViewController alloc] init];
    menuViewController.currentConversation= conversation;
    menuViewController.chatterId = _userId;
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:navi menuViewController:menuViewController];
    menuViewController.containerCtl = frostedViewController;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    frostedViewController.resumeNavigationBar = NO;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    [self.navigationController pushViewController:frostedViewController animated:YES];

    __weak ChatViewController *viewController = chatController;
    if (![self.navigationController.viewControllers.firstObject isKindOfClass:[ChatListViewController class]]) {
        chatController.backBlock = ^(){
            [viewController.frostedViewController.navigationController popViewControllerAnimated:YES];
        };
    }
}

- (IBAction)moreAction:(UIButton *)sender
{
    UIActionSheet *sheet;
    if (_isMyFriend) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"删除朋友", nil];
    } else {
        
        NSString *actionSheetTitle = nil;
        BOOL isBlackUser = [FrendModel typeIsCorrect:_userInfo.type typeWeight:IMFrendWeightTypeBlackList];
        if (isBlackUser) {
            // 如果已经是黑名单,则显示取消屏蔽用户
            actionSheetTitle = @"取消屏蔽用户";
        } else {
            actionSheetTitle = @"屏蔽用户";
        }
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:actionSheetTitle, nil];
    }
    
    [sheet showInView:self.view];
}

- (void)removeContact
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
    __weak typeof(OtherUserInfoViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [frendManager asyncRemoveContactWithUserId:_userId completion:^(BOOL isSuccess, NSInteger errorCode) {
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

/**
 *  屏蔽用户
 */
- (void)blackUser
{
    // 用户类型如果不是黑名单类型,则屏蔽用户
    if (![FrendModel typeIsCorrect:_userInfo.type typeWeight:IMFrendWeightTypeBlackList]) {
        
        __weak typeof(OtherUserInfoViewController *)weakSelf = self;
        TZProgressHUD *hud = [[TZProgressHUD alloc] init];
        [hud showHUDInViewController:weakSelf];
        FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
        
        // 屏蔽用户
        [frendManager asyncBlackContactWithUserId:_userId completion:^(BOOL isSuccess, NSInteger errorCode) {
            [hud hideTZHUD];
            
            if (isSuccess) {
                _userInfo.type = _userInfo.type + IMFrendWeightTypeBlackList;
                [SVProgressHUD showHint:@"已屏蔽用户"];
            }
        }];

    } else {  // 用户类型如果是黑名单类型,则取消屏蔽用户
        __weak typeof(OtherUserInfoViewController *)weakSelf = self;
        TZProgressHUD *hud = [[TZProgressHUD alloc] init];
        [hud showHUDInViewController:weakSelf];
        FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
        
        // 取消屏蔽用户
        [frendManager asyncCancelBlackContactWithUserId:_userId completion:^(BOOL isSuccess, NSInteger errorCode) {
            [hud hideTZHUD];
            _userInfo.type = _userInfo.type - IMFrendWeightTypeBlackList;
            if (isSuccess) {
                [SVProgressHUD showHint:@"取消用户屏蔽成功"];
            }
        }];

    }
}

//显示达人交流的引导页面
- (void)showExpertTipsViewWithView:(UIView *)sourceView
{
    CMPopTipView *tipView = [[CMPopTipView alloc] initWithMessage:@"有问题可以向达人请教噢"];
    tipView.backgroundColor = APP_THEME_COLOR;
    tipView.dismissTapAnywhere = YES;
    tipView.hasGradientBackground = NO;
    tipView.hasShadow = YES;
    tipView.borderColor = APP_THEME_COLOR;
    tipView.sidePadding = 5;
    tipView.maxWidth = 110;
    tipView.has3DStyle = NO;
    [tipView presentPointingAtView:sourceView inView:self.view animated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"kShowExpertTipsView"];
}

#pragma mark - UIActionsheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        NSString *message = nil;
        BOOL isBlackUser = [FrendModel typeIsCorrect:_userInfo.type typeWeight:IMFrendWeightTypeBlackList];
        if (isBlackUser) {
            // 如果已经是黑名单,则显示取消屏蔽用户
            message = @"确定取消屏蔽用户?";
        } else {
            message = @"确定屏蔽用户?";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (_isMyFriend) {
                    [self removeContact];
                } else {
                    [self blackUser];
                }
            }
        }];
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        OthersAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell" forIndexPath:indexPath];
        cell.headerPicArray = _albumArray;
        NSLog(@"%@",cell.headerPicArray);
        return cell;
        
    } else if (indexPath.section == 1) {
        
        OtherUserBasicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicInfoCell" forIndexPath:indexPath];
        cell.information.font = [UIFont systemFontOfSize:14];
        cell.basicLabel.font = [UIFont systemFontOfSize:15];
        cell.basicLabel.text = @"TA的旅行计划";
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
        
    } else if (indexPath.section == 2) {
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zuji" forIndexPath:indexPath];
        cell.nameLabel.text = @"TA的足迹";
        cell.footPrint.textColor = TEXT_COLOR_TITLE;
        
        if (_userInfo.footprintCityCount > 0) {
            cell.footPrint.text = _userInfo.footprintDescription;
            
        } else {
            cell.trajectory.text = @"0国 0个城市";
            cell.footPrint.text = @"未设置足迹";
        }
        
        return cell;
        
    } else if (indexPath.section == 3) {
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
        
    } else  {
        OtherUserBasicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicInfoCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.basicLabel.font = [UIFont systemFontOfSize:16];
            cell.basicLabel.text = @"基本信息";
            cell.information.text = @"";
            
        } else if (indexPath.row == 1){
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
            } else {
                cell.information.text = [NSString stringWithFormat:@"%d",age];
            }
        } else {
            cell.basicLabel.font = [UIFont systemFontOfSize:14];
            cell.basicLabel.text = @"   现住地";
            if (_userInfo.residence.length == 0 || [_userInfo.residence isBlankString] || _userInfo.residence == nil) {
                cell.information.text = @"未设置";
            } else {
                cell.information.text = _userInfo.residence;
            }
            cell.information.font = [UIFont systemFontOfSize:14];
        }
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        PlansListTableViewController *listCtl = [[PlansListTableViewController alloc]initWithUserId:_userInfo.userId];
        listCtl.userName = _userInfo.nickName;
        [self.navigationController pushViewController:listCtl animated:YES];
        
    } else if (indexPath.section == 2){
        FootPrintViewController *footCtl = [[FootPrintViewController alloc] init];
        footCtl.hidesBottomBarWhenPushed = YES;
        footCtl.userId = _userId;
        [self.navigationController pushViewController:footCtl animated:YES];
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
    
    FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
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
        } else {
            [SVProgressHUD showHint:@"添加失败"];
        }
    }];
}

- (void)loadUserProfile:(NSInteger)userId {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [FrendManager loadUserInfoFromServer:userId completion:^(BOOL isSuccess, NSInteger errorCode, FrendModel * __nonnull frend) {
        if (isSuccess) {
            _userInfo = frend;
            [self loadUserAlbum];
            [self updateUserInfo];
        } else {
            [SVProgressHUD showHint:@"请求失败"];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)account.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld/albums", API_USERS, (long)_userId];
    
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
    _albumLabel.text = [NSString stringWithFormat:@"%lu张", (long)_albumArray.count];
}

#pragma mark - buttonMethod

- (void)visitTracks
{
    [MobClick event:@"button_item_tracks"];
    FootPrintViewController *footPrintCtl = [[FootPrintViewController alloc] init];
    footPrintCtl.userId = _userId;
    [self.navigationController pushViewController:footPrintCtl animated:YES];
    
}
- (void)seeOthersPlan
{
    [MobClick event:@"button_item_plan"];
    PlansListTableViewController *listCtl = [[PlansListTableViewController alloc]initWithUserId:_userInfo.userId];
    listCtl.userName = _userInfo.nickName;
    [self.navigationController pushViewController:listCtl animated:YES];
}
@end
