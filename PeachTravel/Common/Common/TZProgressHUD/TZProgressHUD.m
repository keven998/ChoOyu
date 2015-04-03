//
//  TZProgressHUD.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/5/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "TZProgressHUD.h"

@interface TZProgressHUD ()

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
        _statusLabel.font = [UIFont systemFontOfSize:13.0];
        [_backGroundView addSubview:_statusLabel];
    } else {
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    }
    _backGroundView.backgroundColor = [UIColor clearColor];
    _backGroundView.layer.cornerRadius = 5.0;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _backGroundView.center = self.center;
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 1; i < 15; i++) {
        NSString *imageName = [NSString stringWithFormat:@"Loading_Animation_final%d.png", i];
        UIImage *image = [UIImage imageNamed:imageName];
        [images addObject:image];
    }
    _imageView.animationImages = images;
    _imageView.animationDuration = 1.4;
    
    if (status) {
        _imageView.center = CGPointMake(_backGroundView.bounds.size.width/2, _backGroundView.bounds.size.height/2-10);
    } else {
        _imageView.center = CGPointMake(_backGroundView.bounds.size.width/2, _backGroundView.bounds.size.height/2);
    }

    [_backGroundView addSubview:_imageView];
    _backGroundView.clipsToBounds = YES;
    
    [self addSubview:_backGroundView];

}

- (void)showHUDInViewController:(UIViewController *)viewController
{
    [self showHUDInViewController:viewController withStatus:nil];
}

- (void)showHUDInView:(UIView *)contentView
{
    [self initLoadingViewWithStatus:nil];
    [contentView addSubview:self];
    self.center = contentView.center;
    CGRect resetFrame = self.backGroundView.frame;
    CGPoint resetCenter = _imageView.center;
    _imageView.center = CGPointZero;
    [self.backGroundView setFrame:CGRectMake(self.backGroundView.center.x, self.backGroundView.center.y, 0, 0)];
    [self startAnimation];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.backGroundView setFrame:CGRectMake(resetFrame.origin.x, resetFrame.origin.y, resetFrame.size.width, resetFrame.size.height)];
        _imageView.center = resetCenter;
    } completion:^(BOOL finished) {
    }];

}

- (void)showHUDInViewController:(UIViewController *)viewController withStatus:(NSString *)status
{
    _rootViewController = viewController;
    [self initLoadingViewWithStatus:status];
    [_rootViewController.view addSubview:self];
    self.center = _rootViewController.view.center;
    CGRect resetFrame = self.backGroundView.frame;
    CGPoint resetCenter = _imageView.center;
    _imageView.center = CGPointZero;
    [self.backGroundView setFrame:CGRectMake(self.backGroundView.center.x, self.backGroundView.center.y, 0, 0)];
    [self startAnimation];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.backGroundView setFrame:CGRectMake(resetFrame.origin.x, resetFrame.origin.y, resetFrame.size.width, resetFrame.size.height)];
        _imageView.center = resetCenter;
    
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
    if (_imageView.isAnimating) {
        [_imageView stopAnimating];
    }
    [self removeFromSuperview];
}

-(void) startAnimation
{
    [_imageView startAnimating];
}


@end






