//
//  HWDropdownMenu.m
//  黑马微博2期
//
//  Created by apple on 14-10-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWDropdownMenu.h"
#import "CWContainView.h"
@interface HWDropdownMenu()
/**
 *  将来用来显示具体内容的容器
 */
@property (nonatomic, weak) CWContainView *containerView;

@property (nonatomic, weak) UIView * mainView;

@end

@implementation HWDropdownMenu

- (UIView *)containerView
{
    if (!_containerView) {
        
        // 添加一个灰色图片控件
        CWContainView *containerView = [[CWContainView alloc] init];
//        containerView.image = [UIImage imageNamed:@"ArtboardBg"];
        containerView.userInteractionEnabled = YES; // 开启交互
        containerView.alpha = 0.8;
        [self addSubview:containerView];
        self.containerView = containerView;
    }
    return _containerView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 清除颜色
        self.backgroundColor = [UIColor clearColor];
        
        UIView * mainView = [[UIView alloc] init];
        self.mainView = mainView;
        mainView.backgroundColor = [UIColor redColor];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.mainView.frame = self.bounds;
}


+ (instancetype)menu
{
    return [[self alloc] init];
}

- (void)setContent:(UIView *)content
{
    _content = content;
    
    // 调整内容的位置
    content.x = 10;
    content.y = 15;
    
    // 调整内容的宽度
//    content.width = self.containerView.width - 2 * content.x;
    
    // 设置灰色的高度
    self.containerView.height = CGRectGetMaxY(content.frame) + 2;
    // 设置灰色的宽度
    self.containerView.width = CGRectGetMaxX(content.frame) + 10;
    
    // 添加内容到灰色图片中
    [self.containerView addSubview:content];
    
    self.containerView.backgroundColor = [UIColor clearColor];
}


- (void)setContentController:(UIViewController *)contentController
{
    _contentController = contentController;
    
    self.content = contentController.view;
}

/**
 *  显示
 */
- (void)showFrom:(UIView *)from
{
    // 1.获得最上面的窗口
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    
    // 2.添加自己到窗口上
    [window addSubview:self];
  
    
    // 3.设置尺寸
    self.frame = window.bounds;
    
    // 4.调整灰色图片的位置
    // 默认情况下，frame是以父控件左上角为坐标原点
    // 转换坐标系
    CGRect newFrame = [from convertRect:from.bounds toView:window];
//    CGRect newFrame = [from.superview convertRect:from.frame toView:window];
    self.containerView.centerX = CGRectGetMidX(newFrame);
    self.containerView.y = CGRectGetMaxY(newFrame) - 17;
    
    self.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }];
    
    // 通知外界，自己显示了
    if ([self.delegate respondsToSelector:@selector(dropdownMenuDidShow:)]) {
        [self.delegate dropdownMenuDidShow:self];
    }
}

/**
 *  销毁
 */
- (void)dismiss
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });

    
    // 通知外界，自己被销毁了
    if ([self.delegate respondsToSelector:@selector(dropdownMenuDidDismiss:)]) {
        [self.delegate dropdownMenuDidDismiss:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}
@end
