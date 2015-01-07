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
#import "RNGridMenu.h"
#import "AccountManager.h"

@interface ContactDetailViewController ()<UIScrollViewDelegate, RNGridMenuDelegate>
{

    ALDBlurImageProcessor *blurImageProcessor;

}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bigHeaderView;
@property (nonatomic, strong) UIView *smallHeaderFrame;

@property (nonatomic, strong) UIView *signPanel;
@property (nonatomic, strong) UILabel *signLabel;
@property (nonatomic, strong) UIButton *chatBtn;
@property (nonatomic, strong) RNGridMenu *av;

@end

@implementation ContactDetailViewController

@synthesize contact;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = contact.nickName;
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    UIBarButtonItem * moreBarItem = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(moreAction:)];
    [moreBarItem setImage:[UIImage imageNamed:@"ic_more.png"]];
    self.navigationItem.rightBarButtonItem = moreBarItem;
    
    CGFloat width = self.view.bounds.size.width;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = APP_PAGE_COLOR;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    UIView *contentView = [[UIView alloc] initWithFrame:_scrollView.bounds];
    contentView.backgroundColor = APP_PAGE_COLOR;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.autoresizesSubviews = YES;
    [_scrollView addSubview:contentView];
    
    _bigHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 74.0, width-22, 100.0)];
    _bigHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bigHeaderView.clipsToBounds = YES;
    _bigHeaderView.layer.cornerRadius = 2.0;
    [_bigHeaderView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
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
    [smallHeaderView sd_setImageWithURL: [NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    [_smallHeaderFrame addSubview:smallHeaderView];
    
    UIView *wp = [[UIView alloc] initWithFrame:CGRectMake(11.0, 175.0 + 5.0, width - 22.0, 34.0)];
    wp.backgroundColor = [UIColor whiteColor];
    wp.layer.cornerRadius = 2.0;
    wp.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:wp];
    
    CGFloat oy = 172.0 + 5.0 + 34.0 + 10.0;
    UILabel *nickPanel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, oy, width - 22.0, 54.0)];
    nickPanel.backgroundColor = [UIColor whiteColor];
    nickPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    nickPanel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    nickPanel.font = [UIFont systemFontOfSize:14.0];
    nickPanel.layer.cornerRadius = 2.0;
    nickPanel.text = [NSString stringWithFormat:@"   昵称：%@", contact.nickName];
    [contentView addSubview:nickPanel];
    
    oy += 55.0;
    UILabel *idPanel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, oy, width - 22.0, 54.0)];
    idPanel.backgroundColor = [UIColor whiteColor];
    idPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    idPanel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    idPanel.font = [UIFont systemFontOfSize:14.0];
    idPanel.layer.cornerRadius = 2.0;
    idPanel.text = [NSString stringWithFormat:@"   桃号：%@", contact.userId];
    [contentView addSubview:idPanel];
    
    oy += 55.0;
    _signPanel = [[UIView alloc] initWithFrame:CGRectMake(11.0, oy, width - 22.0, 54.0)];
    _signPanel.backgroundColor = [UIColor whiteColor];
    _signPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:_signPanel];
    
    _signLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, oy, width - 20.0, 54.0)];
    _signLabel.numberOfLines = 0.;
    _signLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    _signLabel.font = [UIFont systemFontOfSize:14.0];
    _signLabel.layer.cornerRadius = 2.0;
    if (contact.signature) {
        _signLabel.text = [NSString stringWithFormat:@"   旅行签名：%@",contact.signature];
    } else {
        _signLabel.text = [NSString stringWithFormat:@"   旅行签名：no签名"];
        
    }
    [_signPanel addSubview:_signLabel];
    
    
    _chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 108.0, 30.0)];
    [_chatBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    _chatBtn.clipsToBounds = YES;
    [_chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_chatBtn setTitle:@"Talk" forState:UIControlStateNormal];
    _chatBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _chatBtn.layer.cornerRadius = 2.0;
    [_chatBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:_chatBtn];
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

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    
    _av.delegate = nil;
    _av = nil;
}

#pragma - mark IBAction

- (IBAction)chat:(id)sender {
    if (_goBackToChatViewWhenClickTalk) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:contact.easemobUser isGroup:NO];
    chatCtl.title = contact.nickName;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    for (EMConversation *conversation in conversations) {
        if ([conversation.chatter isEqualToString:contact.easemobUser]) {
            [conversation markAllMessagesAsRead:YES];
            break;
        }
    }
    [self.navigationController pushViewController:chatCtl animated:YES];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreAction:(UIButton *)sender
{
    NSInteger numberOfOptions = 1;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_delete_user.png"] title:@"删除桃友"],
                       ];
    
    _av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    _av.backgroundColor = [UIColor clearColor];
    _av.delegate = self;
    [_av showInViewController:self.navigationController center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

- (void)removeContact
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_DELETE_CONTACTS, self.contact.userId];
    
     __weak typeof(ContactDetailViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf.navigationController];
    
    //删除联系人
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [accountManager removeContact:self.contact.userId];
            [SVProgressHUD showHint:@"OK!成功删除～"];
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

#pragma mark - RNGridMenuDelegate

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    if (itemIndex == 0) {
        [self removeContact];
    }
    _av = nil;
}

- (void)gridMenuWillDismiss:(RNGridMenu *)gridMenu
{
    _av = nil;
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
