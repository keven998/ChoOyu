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

@interface ContactDetailViewController ()<UIScrollViewDelegate> {

    ALDBlurImageProcessor *blurImageProcessor;

}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bigHeaderView;
@property (nonatomic, strong) UIView *smallHeaderFrame;

@property (nonatomic, strong) UIView *signPanel;
@property (nonatomic, strong) UILabel *signLabel;
@property (nonatomic, strong) UIButton *chatBtn;

@end

@implementation ContactDetailViewController

@synthesize contact;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"信息";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
//    CGFloat width = kWindowWidth;
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
    
    _bigHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 64.0, width, 108.0)];
    _bigHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bigHeaderView.clipsToBounds = YES;
    [_bigHeaderView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"ic_setting_avatar.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
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
    
    _smallHeaderFrame = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 64.0)];
    _smallHeaderFrame.backgroundColor = [UIColor whiteColor];
//    smallHeaderFrame.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _smallHeaderFrame.layer.cornerRadius = 32.0;
    _smallHeaderFrame.center = CGPointMake(self.view.bounds.size.width/2.0, 172.0 + 64.0);
    [self.view addSubview:_smallHeaderFrame];
    
    UIImageView *smallHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(2.0, 2.0, 60.0, 60.0)];
    smallHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [smallHeaderView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:nil];
    smallHeaderView.layer.cornerRadius = 30.0;
    smallHeaderView.clipsToBounds = YES;
    [_smallHeaderFrame addSubview:smallHeaderView];
    
    UIView *wp = [[UIView alloc] initWithFrame:CGRectMake(10.0, 172.0 + 5.0, width - 20.0, 44.0)];
    wp.backgroundColor = [UIColor whiteColor];
    wp.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:wp];
    
    CGFloat oy = 172.0 + 5.0 + 44.0 + 10.0;
    UILabel *nickPanel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, oy, width - 20.0, 50.0)];
    nickPanel.backgroundColor = [UIColor whiteColor];
    nickPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    nickPanel.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
    nickPanel.textColor = UIColorFromRGB(0x393939);
    nickPanel.font = [UIFont systemFontOfSize:15.0];
    nickPanel.text = [NSString stringWithFormat:@"   昵称：%@", contact.nickName];
    [contentView addSubview:nickPanel];
    
    oy += 51.0;
    UILabel *idPanel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, oy, width - 20.0, 50.0)];
    idPanel.backgroundColor = [UIColor whiteColor];
    idPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    idPanel.textColor = UIColorFromRGB(0x393939);
    idPanel.font = [UIFont systemFontOfSize:15.0];
    idPanel.text = [NSString stringWithFormat:@"   桃号：%@", contact.userId];
    [contentView addSubview:idPanel];
    
    oy += 51.0;
    _signPanel = [[UIView alloc] initWithFrame:CGRectMake(10.0, oy, width - 20.0, 50.0)];
    _signPanel.backgroundColor = [UIColor whiteColor];
    _signPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:_signPanel];
    
    _signLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, oy, width - 20.0, 50.0)];
    _signLabel.numberOfLines = 0.;
    _signLabel.textColor = UIColorFromRGB(0x393939);
    _signLabel.font = [UIFont systemFontOfSize:15.0];
    if (contact.signature) {
        _signLabel.text = [NSString stringWithFormat:@"   旅行签名：%@",contact.signature];
    } else {
        _signLabel.text = [NSString stringWithFormat:@"   旅行签名：未设置签名"];
        
    }
    [_signPanel addSubview:_signLabel];
    
    
    _chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 108.0, 34.0)];
    _chatBtn.backgroundColor = UIColorFromRGB(0xee528c);
    [_chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_chatBtn setTitle:@"Talk" forState:UIControlStateNormal];
    _chatBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
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
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    _scrollView.delegate = nil;
    _scrollView = nil;
}

#pragma - mark IBAction
- (IBAction)chat:(id)sender {
    
    ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:contact.easemobUser isGroup:NO];
    chatCtl.title = contact.nickName;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    for (EMConversation *conversation in conversations) {
        if ([conversation.chatter isEqualToString:contact.easemobUser]) {
            [conversation markMessagesAsRead:YES];
            break;
        }
    }
    [self.navigationController pushViewController:chatCtl animated:YES];
}

#pragma UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        CGFloat y = _scrollView.contentOffset.y;
        
        if (blurImageProcessor != nil) {
            [blurImageProcessor asyncBlurWithRadius: 99 + y
                                         iterations: 1
                                       successBlock: ^(UIImage *bimg) {
                                           _bigHeaderView.image = bimg;
                                       } errorBlock: ^( NSNumber *errorCode ) {
                                           NSLog( @"Error code: %d", [errorCode intValue] );
                                       }];
        }
    
        CGRect rect = _bigHeaderView.frame;
        rect.size.height = 108.0 - y;
        rect.origin.y = 64.0;
        _bigHeaderView.frame = rect;
        
        CGRect rect1 = _smallHeaderFrame.frame;
        rect1.origin.y = 140.0 - y;
        _smallHeaderFrame.frame = rect1;
        
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
