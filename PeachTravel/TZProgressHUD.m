//
//  TZProgressHUD.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/5/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "TZProgressHUD.h"

@interface TZProgressHUD ()

@property (nonatomic, strong) UIImageView *progressView;   //旋转的 view
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *statusLabel;   //提示的语言
@property (nonatomic, weak) UIViewController *rootViewController;

@end

@implementation TZProgressHUD

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTZHUD)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)dealloc {
    NSLog(@"ZTProgressHUD销毁掉了");
}

- (void)setStatus:(NSString *)status
{
    _status = status;
    _statusLabel.text = _status;
}

- (void)initLoadingViewWithStatus:(NSString *)status
{
    if (status) {
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 140)];
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 150, 30)];
        _statusLabel.text = status;
        _statusLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
        [_backGroundView addSubview:_statusLabel];
    } else {
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    }
    _backGroundView.backgroundColor = [UIColor whiteColor];
    _backGroundView.layer.cornerRadius = 5.0;
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_pb_earth.png"]];
    _imageView.image = [UIImage imageNamed:@"ic_pb_earth.png"];
    _backGroundView.center = self.view.center;
    if (status) {
        _imageView.center = CGPointMake(_backGroundView.bounds.size.width/2, _backGroundView.bounds.size.height/2-10);
    } else {
        _imageView.center = CGPointMake(_backGroundView.bounds.size.width/2, _backGroundView.bounds.size.height/2);
    }
    _progressView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_progress.png"]];
    _progressView.center = _imageView.center;
    [_backGroundView addSubview:_progressView];
    [_backGroundView addSubview:_imageView];
    _backGroundView.clipsToBounds = YES;
    
    [self.view addSubview:_backGroundView];

}

- (void)showHUDInViewController:(UIViewController *)viewController
{
    [self showHUDInViewController:viewController withStatus:nil];
}

- (void)showHUDInViewController:(UIViewController *)viewController withStatus:(NSString *)status
{
    _rootViewController = viewController;
    [self initLoadingViewWithStatus:status];
    //如果要显示的位置不是一个 navigationcontroller。这么设置是为了达到全屏的效果
    if (![_rootViewController isKindOfClass:[UINavigationController class]]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rootViewController.navigationController.view.frame.size.width, 64)];
        view.tag = 100;
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [_rootViewController.navigationController.view addSubview:view];
    }
    [_rootViewController addChildViewController:self];
    [_rootViewController.view addSubview:self.view];
    CGRect resetFrame = self.backGroundView.frame;
    CGPoint resetCenter = _imageView.center;
    _imageView.center = CGPointZero;
    _progressView.center =CGPointZero;
    [self.backGroundView setFrame:CGRectMake(self.backGroundView.center.x, self.backGroundView.center.y, 0, 0)];
    [self startAnimation];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.backGroundView setFrame:CGRectMake(resetFrame.origin.x-2.5, resetFrame.origin.y-2.5, resetFrame.size.width, resetFrame.size.height)];
        _imageView.center = resetCenter;
        _progressView.center = _imageView.center;
    } completion:^(BOOL finished) {
    }];

}

- (void)showHUD
{
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            [self showHUDInViewController:window.rootViewController];
            break;
        }
    }
}

- (void)hideTZHUD
{
    if (!_rootViewController) {
        return;
    }
    UIView *viewInNavi;
    // 移除为了实现全屏效果而再 navigationcontroller 上加的一个阴影 view
    if (![_rootViewController isKindOfClass:[UINavigationController class]]) {
        for (UIView *view in _rootViewController.navigationController.view.subviews) {
            if (view.tag == 100) {
                viewInNavi = view;
                break;
            }
        }
    }
   
    [UIView animateWithDuration:0.15 animations:^{
        self.view.alpha = 0;
        viewInNavi.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self willMoveToParentViewController:nil];
        [self removeFromParentViewController];
        [viewInNavi removeFromSuperview];
    }];
}

-(void) startAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 1.0 ];
    rotationAnimation.duration = 1.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [_progressView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


@end






