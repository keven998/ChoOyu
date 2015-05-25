//
//  ContactDetailViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/11/21.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "ChatViewController.h"
#import "ALDBlurImageProcessor.h"
#import "AccountManager.h"
#import "ChatSettingViewController.h"
#import "REFrostedViewController.h"

@interface ContactDetailViewController ()<UIScrollViewDelegate, UIActionSheetDelegate>
{
    ALDBlurImageProcessor *blurImageProcessor;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bigHeaderView;
@property (nonatomic, strong) UIView *smallHeaderFrame;

@property (nonatomic, strong) UIView *signPanel;
@property (nonatomic, strong) UILabel *signLabel;
@property (nonatomic, strong) UIButton *chatBtn;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation ContactDetailViewController

@synthesize contact;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = contact.nickName;
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    [moreBtn setImage:[UIImage imageNamed:@"ic_more.png"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    
    CGFloat width = self.view.bounds.size.width;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = APP_PAGE_COLOR;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    _contentView = [[UIView alloc] initWithFrame:_scrollView.bounds];
    _contentView.backgroundColor = APP_PAGE_COLOR;
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _contentView.autoresizesSubviews = YES;
    
    CGSize size = [contact.signature sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]}];
    
    [_contentView setFrame:CGRectMake(_contentView.frame.origin.x, _contentView.frame.origin.y, _contentView.frame.size.width, _contentView.frame.size.height+size.height+100)];

    [_scrollView addSubview:_contentView];
    
    _bigHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 74.0, width-22, 100.0)];
    _bigHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bigHeaderView.clipsToBounds = YES;
    _bigHeaderView.layer.cornerRadius = 2.0;
    [_bigHeaderView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"person_disabled"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
        if (image == nil) return ;
        blurImageProcessor = [[ALDBlurImageProcessor alloc] initWithImage: image];
        [blurImageProcessor asyncBlurWithRadius: 99
                                     iterations: 1
                                   successBlock: ^(UIImage *bimg) {
                                       _bigHeaderView.image = bimg;
                                   } errorBlock: ^( NSNumber *errorCode ) {
                                         NSLog( @"Error code: %d", [errorCode intValue] );
                                   }];
    }];
    _bigHeaderView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_bigHeaderView];
    
    _smallHeaderFrame = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 68.0, 68.0)];
    _smallHeaderFrame.backgroundColor = [UIColor whiteColor];
    _smallHeaderFrame.layer.cornerRadius = 34.0;
    _smallHeaderFrame.center = CGPointMake(self.view.bounds.size.width/2.0, 172.0 + 66.0);
    [self.view addSubview:_smallHeaderFrame];
    
    UIImageView *smallHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 3.0, 62.0, 62.0)];
    smallHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [smallHeaderView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:nil];
    smallHeaderView.layer.cornerRadius = 30.0;
    smallHeaderView.clipsToBounds = YES;
    [smallHeaderView sd_setImageWithURL: [NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"person_disabled"]];
    [_smallHeaderFrame addSubview:smallHeaderView];
    
    UIImageView *genderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(47, 47, 17, 17)];
    if ([contact.gender isEqualToString:@"M"]) {
        genderImageView.image = [UIImage imageNamed:@"ic_gender_man.png"];
        
    }
    if ([contact.gender isEqualToString:@"F"]) {
        genderImageView.image  = [UIImage imageNamed:@"ic_gender_lady.png"];
    }
    if ([contact.gender isEqualToString:@"U"]) {
        genderImageView.image  = nil;
    }
    [_smallHeaderFrame addSubview:genderImageView];
    
    UIView *wp = [[UIView alloc] initWithFrame:CGRectMake(11.0, 175.0 + 5.0, width - 22.0, 34.0)];
    wp.backgroundColor = [UIColor whiteColor];
    wp.layer.cornerRadius = 2.0;
    wp.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_contentView addSubview:wp];
    
    CGFloat oy = 172.0 + 5.0 + 34.0 + 10.0;
    UILabel *nickPanel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, oy, width - 22.0, 54.0)];
    nickPanel.backgroundColor = [UIColor whiteColor];
    nickPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    nickPanel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    nickPanel.font = [UIFont systemFontOfSize:14.0];
    nickPanel.layer.cornerRadius = 2.0;
    nickPanel.text = [NSString stringWithFormat:@"   名字：%@", contact.nickName];
    [_contentView addSubview:nickPanel];
    
    oy += 55.0;
    UILabel *idPanel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, oy, width - 22.0, 54.0)];
    idPanel.backgroundColor = [UIColor whiteColor];
    idPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    idPanel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    idPanel.font = [UIFont systemFontOfSize:14.0];
    idPanel.layer.cornerRadius = 2.0;
    idPanel.text = [NSString stringWithFormat:@"   ID：%@", contact.userId];
    [_contentView addSubview:idPanel];
    
    oy += 55.0;
    _signPanel = [[UIView alloc] initWithFrame:CGRectMake(11.0, oy, width - 22.0, 54.0)];
    _signPanel.backgroundColor = [UIColor whiteColor];
    _signPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_contentView addSubview:_signPanel];
    
    _signLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, oy, width - 40.0, 54.0)];
    _signLabel.numberOfLines = 0.;
    _signLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    _signLabel.font = [UIFont systemFontOfSize:14.0];
    _signLabel.layer.cornerRadius = 2.0;
    if (contact.signature) {
        _signLabel.text = [NSString stringWithFormat:@"旅行签名：%@",contact.signature];
    } else {
        _signLabel.text = [NSString stringWithFormat:@"旅行签名：no签名"];
        
    }
    [_signPanel addSubview:_signLabel];
    
    
    _chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 108.0, 30.0)];
    [_chatBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    _chatBtn.clipsToBounds = YES;
    [_chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_chatBtn setTitle:@"聊天" forState:UIControlStateNormal];
    _chatBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _chatBtn.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
    _chatBtn.layer.cornerRadius = 2.0;
    [_chatBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_chatBtn];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize size = [contact.signature sizeWithAttributes:@{NSFontAttributeName : _signLabel.font}];
    _signLabel.frame = CGRectMake(_signLabel.frame.origin.x, 16.0, _signLabel.frame.size.width, size.height);
    [_signLabel sizeToFit];
    
    CGFloat h = _signLabel.frame.size.height + 30;
    h = h > 50.0 ? h : 50.0;
    
    _signPanel.frame = CGRectMake(_signPanel.frame.origin.x, _signPanel.frame.origin.y, _signPanel.frame.size.width, h);
    _chatBtn.center = CGPointMake(self.view.bounds.size.width/2.0, _signPanel.frame.origin.y + CGRectGetHeight(_signPanel.frame) + 35.0 + 17.0);
    
    CGFloat y = _chatBtn.frame.origin.y + _chatBtn.frame.size.height + 10.0;
    
    y = y > _scrollView.bounds.size.height - 64.0 ? y : _scrollView.bounds.size.height - 63.0;
    _scrollView.contentSize = CGSizeMake(0.0, y);
    
    y = _scrollView.contentOffset.y;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_friend_information"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_friend_information"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
    _scrollView.delegate = nil;
    _scrollView = nil;
    
    [blurImageProcessor cancelAsyncBlurOperations];
    blurImageProcessor = nil;
    _bigHeaderView = nil;
}

#pragma - mark IBAction

- (IBAction)chat:(id)sender {
    [MobClick event:@"event_talk_with_it"];
    if (_goBackToChatViewWhenClickTalk) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:contact.userId.integerValue chatType:IMChatTypeIMChatSingleType];
    chatCtl.title = contact.nickName;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    for (EMConversation *conversation in conversations) {
        if ([conversation.chatter isEqualToString:contact.easemobUser]) {
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

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_DELETE_CONTACTS, self.contact.userId];
    
     __weak typeof(ContactDetailViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    //删除联系人
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [accountManager removeContact:self.contact.userId];
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

#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        CGFloat y = _scrollView.contentOffset.y;
        
        if (blurImageProcessor != nil) {
            if (99 + y >= 0) {
                [blurImageProcessor asyncBlurWithRadius: 99 + y
                                             iterations: 1
                                           successBlock: ^(UIImage *bimg) {
                                               _bigHeaderView.image = bimg;
                                           } errorBlock: ^( NSNumber *errorCode ) {
                                               NSLog( @"Error code: %d", [errorCode intValue] );
                                           }];
            }
        }
    
        CGRect rect = _bigHeaderView.frame;
        rect.size.height = 100.0 - y;
        rect.origin.y = 74.0;
        _bigHeaderView.frame = rect;
        
        CGRect rect1 = _smallHeaderFrame.frame;
        rect1.origin.y = 140.0 - y;
        _smallHeaderFrame.frame = rect1;
    }
}


@end
