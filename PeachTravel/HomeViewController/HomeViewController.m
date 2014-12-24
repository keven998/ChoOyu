//
//  HomeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "HomeViewController.h"
#import "ICETutorialController.h"
#import "ToolBoxViewController.h"
#import "HotDestinationCollectionViewController.h"
#import "MineTableViewController.h"
#import "RDVTabBarItem.h"

@interface HomeViewController ()<UIGestureRecognizerDelegate, ICETutorialControllerDelegate>

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) ICETutorialController *viewController;

@property (nonatomic, strong) ToolBoxViewController *toolBoxCtl;
@property (nonatomic, strong) HotDestinationCollectionViewController *hotDestinationCtl;
@property (nonatomic, strong) MineTableViewController *mineCtl;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self setupViewControllers];
    [self setupConverView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

    if (_coverView != nil) {
        NSString *backGroundImageStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"backGroundImage"];
        [_coverView sd_setImageWithURL:[NSURL URLWithString:backGroundImageStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                _coverView.image = [UIImage imageNamed:@"tutorial_background_01.jpg"];
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
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    _coverView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _coverView.userInteractionEnabled = YES;
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    CALayer *layer = [_coverView layer];
    layer.shadowColor = [UIColor colorWithWhite:0. alpha:1.0].CGColor;
    layer.shadowOffset = CGSizeMake(2.5, 0.0);
    layer.shadowOpacity = 0.25;
    layer.shadowRadius = 2.5;
    [self.view addSubview:_coverView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0, h - 49.0, w, 49.0)];
    bottomView.backgroundColor = APP_THEME_COLOR;
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    bottomView.userInteractionEnabled = YES;
    [_coverView addSubview:bottomView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(w - 128.0, 0.0, 128.0, 49.0)];
    [button setTitle:@"开启旅行>>" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    pan.delegate = self;
    [_coverView addGestureRecognizer:pan];
    _coverView.backgroundColor = [UIColor whiteColor];
    
    if (!shouldSkipIntroduce && kShouldShowIntroduceWhenFirstLaunch) {
        [self beginIntroduce];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[AppUtils alloc] init].appVersion];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture
- (void) swipe:(UIPanGestureRecognizer*)gesture {
    UIView *view = [gesture view];
    CGPoint velocity = [gesture velocityInView:view];
    CGFloat x = velocity.x;
    CGPoint transtion = [gesture translationInView:view];
    CGFloat panX = transtion.x;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (panX >= 0.0) return;
        CGRect frame = view.frame;
        frame.origin.x = panX;
        view.frame = frame;
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (panX <= -CGRectGetWidth(self.view.bounds) * 0.33) {
            [self dismiss:nil];
        } else if (x < -10.0 && panX < 0.0) {
            [self dismiss:nil];
        } else if (x > 10.0 && panX < 0.0) {
            CGRect srcFrame = _coverView.frame;
            srcFrame.origin.x = 0.0;
            void (^closeAnim)(void) = ^(void) {
                _coverView.frame = srcFrame;
            };
            
            UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight;
            [UIView animateWithDuration:0.2 delay:0.0 options:options animations:closeAnim completion:nil];
        } else {
            CGRect frame = view.frame;
            frame.origin.x = 0.0;
            view.frame = frame;
        }
    }
}

#pragma mark - IBActions

- (void)dismiss:(id)sender
{
    CGRect srcFrame = _coverView.frame;
    srcFrame.origin.x = -srcFrame.size.width;
    void (^closeAnim)(void) = ^(void) {
        _coverView.frame = srcFrame;
    };
    
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight;
    [UIView animateWithDuration:0.2 delay:0.0 options:options animations:closeAnim completion:^(BOOL finished) {
        [_coverView removeFromSuperview];
        _coverView = nil;
    }];
}

#pragma mark - loadStroy
- (void)loadData
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
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
    [_coverView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"tutorial_background_01.jpg"]];
    [[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:@"backGroundImage"];
}

#pragma mark - help
- (void)beginIntroduce
{
    _coverView.hidden = YES;
    ICETutorialPage *layer1 = [[ICETutorialPage alloc] initWithTitle:@"Picture 1"
                                                            subTitle:@"Champs-Elysées by night"
                                                         pictureName:@"tutorial_background_00@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer2 = [[ICETutorialPage alloc] initWithTitle:@"Picture 2"
                                                            subTitle:@"The Eiffel Tower with\n cloudy weather"
                                                         pictureName:@"tutorial_background_01@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer3 = [[ICETutorialPage alloc] initWithTitle:@"Picture 3"
                                                            subTitle:@"An other famous street of Paris"
                                                         pictureName:@"tutorial_background_02@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer4 = [[ICETutorialPage alloc] initWithTitle:@"Picture 4"
                                                            subTitle:@"The Eiffel Tower with a better weather"
                                                         pictureName:@"tutorial_background_03@2x.jpg"
                                                            duration:3.0];
    ICETutorialPage *layer5 = [[ICETutorialPage alloc] initWithTitle:@"Picture 5"
                                                            subTitle:@"The Louvre's Museum Pyramide"
                                                         pictureName:@"tutorial_background_04@2x.jpg"
                                                            duration:3.0];
    NSArray *tutorialLayers = @[layer1,layer2,layer3,layer4,layer5];
    
    // Set the common style for the title.
    ICETutorialLabelStyle *titleStyle = [[ICETutorialLabelStyle alloc] init];
    [titleStyle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0f]];
    [titleStyle setTextColor:[UIColor whiteColor]];
    [titleStyle setLinesNumber:1];
    [titleStyle setOffset:180];
    [[ICETutorialStyle sharedInstance] setTitleStyle:titleStyle];
    
    // Set the subTitles style with few properties and let the others by default.
    [[ICETutorialStyle sharedInstance] setSubTitleColor:[UIColor whiteColor]];
    [[ICETutorialStyle sharedInstance] setSubTitleOffset:150];
    
    // Init tutorial.
    self.viewController = [[ICETutorialController alloc] initWithPages:tutorialLayers
                                                              delegate:self];
    [self.view addSubview:self.viewController.view];
    
    // Run it.
    [self.viewController startScrolling];
}

- (void)tutorialControllerDidReachLastPage:(ICETutorialController *)tutorialController
{
    _coverView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.viewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.viewController.view removeFromSuperview];
        self.viewController = nil;
    }];
}

- (void)setupViewControllers
{
    _toolBoxCtl = [[ToolBoxViewController alloc] init];
    _toolBoxCtl.rootCtl = self;
    UINavigationController *firstNavigationController = [[UINavigationController alloc]
                                                         initWithRootViewController:_toolBoxCtl];
    
    _hotDestinationCtl = [[HotDestinationCollectionViewController alloc] init];
    _hotDestinationCtl.rootCtl = self;
    UINavigationController *secondNavigationController = [[UINavigationController alloc]
                                                          initWithRootViewController:_hotDestinationCtl];
    
    _mineCtl = [[MineTableViewController alloc] init];
    _mineCtl.rootCtl = self;
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
    
//    UIImage *finishedImage = [ConvertMethods createImageWithColor:APP_PAGE_COLOR];
//    UIImage *unfinishedImage = [ConvertMethods createImageWithColor:APP_PAGE_COLOR];
    
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
        
//        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}
@end
