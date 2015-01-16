//
//  HomeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "HomeViewController.h"
#import "ToolBoxViewController.h"
#import "HotDestinationCollectionViewController.h"
#import "MineTableViewController.h"
#import "RDVTabBarItem.h"
#import <QuartzCore/QuartzCore.h>
#import "PageOne.h"
#import "PageTwo.h"
#import "PageThree.h"
#import "EAIntroView.h"

@interface HomeViewController ()<UIGestureRecognizerDelegate, EAIntroDelegate>

@property (nonatomic, strong) UIImageView *coverView;

@property (nonatomic, strong) ToolBoxViewController *toolBoxCtl;
@property (nonatomic, strong) HotDestinationCollectionViewController *hotDestinationCtl;
@property (nonatomic, strong) MineTableViewController *mineCtl;

@property (nonatomic, strong) PageOne *pageView1;
@property (nonatomic, strong) PageTwo *pageView2;
@property (nonatomic, strong) PageThree *pageView3;

@end

@implementation HomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViewControllers];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self setupConverView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_shouldJumpToChatListWhenAppLaunch && _coverView != nil) {
        [_coverView removeFromSuperview];
        _coverView = nil;
        [self jumpToChatListCtl];
    }
    
    if (_coverView != nil) {
        NSString *backGroundImageStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"backGroundImage"];
        [_coverView sd_setImageWithURL:[NSURL URLWithString:backGroundImageStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                _coverView.image = [UIImage imageNamed:@"story_default.png"];
            }
        }];
        [self loadData];
    }
    self.navigationController.navigationBar.hidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void) setupConverView {

    _coverView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _coverView.userInteractionEnabled = YES;
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
   
    [self.view addSubview:_coverView];
    
    _coverView.backgroundColor = [UIColor whiteColor];

    if (!shouldSkipIntroduce && kShouldShowIntroduceWhenFirstLaunch) {
        [self beginIntroduce];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[AppUtils alloc] init].appVersion];
    } else {
        [self performSelector:@selector(dismiss:) withObject:nil afterDelay:2.5];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

- (void)dismiss:(id)sender
{
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight;
    [UIView animateWithDuration:0.2 delay:0.0 options:options animations:^{
        _coverView.alpha = 0.2;
    }  completion:^(BOOL finished) {
        _coverView.alpha = 0;
        [_coverView removeFromSuperview];
        _coverView = nil;
    }];
}

/**
 *  跳转到聊天列表
 */
- (void)jumpToChatListCtl
{
    if (_toolBoxCtl) {
        [_toolBoxCtl jumpIM:nil];
    }
}

/**
 *  跳转到web 界面
 */
- (void)jumpToWebViewCtl
{
    
}

#pragma mark - loadStroy
- (void)loadData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithFloat:self.view.frame.size.width*2] forKey:@"width"];
    [params setObject:[NSNumber numberWithFloat:self.view.frame.size.height*2] forKey:@"height"];
    
    //获取封面故事接口
    [manager GET:API_GET_COVER_STORIES parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (!([[[responseObject objectForKey:@"result"] objectForKey:@"image"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"backGroundImage"]])) {
                [self updateBackgroundData:[[responseObject objectForKey:@"result"] objectForKey:@"image"]];
            }
        } else {
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void)updateBackgroundData:(NSString *)imageUrl
{
    [_coverView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"story_default.png"]];
    [[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:@"backGroundImage"];
}

#pragma mark - help
- (void)beginIntroduce
{
    _coverView.hidden = YES;
    EAIntroPage *page1 = [EAIntroPage page];
    _pageView1 = [[PageOne alloc] initWithFrame:self.view.bounds];
    page1.bgImage = _pageView1.backGroundImageView;
    page1.titleIconView = _pageView1.titleView;
    page1.titleIconPositionY = self.view.bounds.size.height/2-30;
    
    EAIntroPage *page2 = [EAIntroPage page];
    _pageView2 = [[PageTwo alloc] initWithFrame:self.view.bounds];
    page2.bgImage = _pageView2.backGroundImageView;
    page2.titleIconView = _pageView2.titleView;
    page2.titleIconPositionY = self.view.bounds.size.height/2-30;
    
    
    EAIntroPage *page3 = [EAIntroPage page];
    _pageView3 = [[PageThree alloc] initWithFrame:self.view.bounds];
    page3.bgImage = _pageView3.backGroundImageView;
    page3.titleIconView = _pageView3.titleView;
    page3.titleIconPositionY = self.view.bounds.size.height/2-40;
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    [intro setDelegate:self];
    
    [intro showInView:self.view animateDuration:0];
}

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex
{
    if (pageIndex == 0) {
        [_pageView1 startAnimation];
    }
    if (pageIndex == 1) {
        [_pageView2 startAnimation];
    }
    if (pageIndex == 2) {
        [_pageView3 startAnimation];
    }
}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex
{
    if (pageIndex == 0) {
        [_pageView1 stopAnimation];
    }
}

- (void)introDidFinish:(EAIntroView *)introView
{
    
}
//- (void)tutorialControllerDidReachLastPage:(ICETutorialController *)tutorialController
//{
//    _coverView.hidden = NO;
//    [UIView animateWithDuration:0.5 animations:^{
//        self.viewController.view.alpha = 0;
//    } completion:^(BOOL finished) {
//        [self.viewController stopScrolling];
//        [self.viewController.view removeFromSuperview];
//        self.viewController = nil;
//    }];
//}

- (void)setupViewControllers
{
    _toolBoxCtl = [[ToolBoxViewController alloc] init];
    UINavigationController *firstNavigationController = [[UINavigationController alloc]
                                                         initWithRootViewController:_toolBoxCtl];
    
    _hotDestinationCtl = [[HotDestinationCollectionViewController alloc] init];
    UINavigationController *secondNavigationController = [[UINavigationController alloc]
                                                          initWithRootViewController:_hotDestinationCtl];
    
    _mineCtl = [[MineTableViewController alloc] init];
    UINavigationController *thirdNavigationController = [[UINavigationController alloc]
                                                         initWithRootViewController:_mineCtl];
    
    [self setViewControllers:@[firstNavigationController, secondNavigationController,
                               thirdNavigationController]];
    [self customizeTabBarForController];
}

- (void)customizeTabBarForController
{
    self.tabBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 49);
    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    spaceView.backgroundColor = UIColorFromRGB(0xcfcfcf);
    [self.tabBar addSubview:spaceView];
    
    NSArray *tabBarItemImages = @[@"ic_tao", @"ic_loc", @"ic_person"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        item.titlePositionAdjustment = UIOffsetMake(0, 6);
        item.selectedTitleAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:11.0], NSForegroundColorAttributeName : APP_THEME_COLOR};
        item.unselectedTitleAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:11.0], NSForegroundColorAttributeName : TEXT_COLOR_TITLE_SUBTITLE};
        
        item.itemHeight = 49.0;
        item.backgroundColor = [UIColor whiteColor];
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(item.bounds.size.width-1, 8, 0.5, 33)];
        spaceView.backgroundColor = APP_DIVIDER_COLOR;
        [item addSubview:spaceView];
        
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}
@end
