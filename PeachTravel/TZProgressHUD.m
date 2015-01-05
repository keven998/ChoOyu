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

- (UIView *)backGroundView
{
    if (!_backGroundView) {
        
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
        _backGroundView.center = self.view.center;
        _backGroundView.backgroundColor = [UIColor whiteColor];
        _backGroundView.layer.cornerRadius = 5.0;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 59, 59)];
        _imageView.image = [UIImage imageNamed:@"ic_pb_earth.png"];
        _imageView.center = CGPointMake(_backGroundView.bounds.size.width/2, _backGroundView.bounds.size.height/2);
        _progressView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_progress.png"]];
        _progressView.center = _imageView.center;
        [_backGroundView addSubview:_progressView];
        [_backGroundView addSubview:_imageView];
        _backGroundView.clipsToBounds = YES;
        [self.view addSubview:_backGroundView];
    }
    return _backGroundView;
}

- (void)showHUDInViewController:(UIViewController *)viewController
{
    _rootViewController = viewController;
    [_rootViewController addChildViewController:self];
    [_rootViewController.view addSubview:self.view];
    CGPoint resetPoint = self.backGroundView.frame.origin;
    _imageView.center = CGPointZero;
    _progressView.center =CGPointZero;
    [self.backGroundView setFrame:CGRectMake(self.backGroundView.center.x, self.backGroundView.center.y, 0, 0)];
    [self startAnimation];

    [UIView animateWithDuration:0.3 animations:^{
        NSLog(@"%@",NSStringFromCGPoint(_progressView.center));
        [self.backGroundView setFrame:CGRectMake(resetPoint.x-2.5, resetPoint.y-2.5, 200, 150)];
        _imageView.center = CGPointMake(_backGroundView.bounds.size.width/2, _backGroundView.bounds.size.height/2);
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
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self willMoveToParentViewController:nil];
        [self removeFromParentViewController];
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






