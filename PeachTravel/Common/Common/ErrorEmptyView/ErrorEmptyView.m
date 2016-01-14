//
//  ErrorEmptyView.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/14/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "ErrorEmptyView.h"

@implementation ErrorEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_errorEmpty.png"]];
    imageView.center = CGPointMake(self.bounds.size.width/2, imageView.bounds.size.height/2+20);
    [self addSubview:imageView];
    
    UIButton *reloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    reloadBtn.center = CGPointMake(self.bounds.size.width/2, imageView.frame.size.height + imageView.frame.origin.y + 40);
    [reloadBtn setTitleColor:UIColorFromRGB(0xF58667) forState:UIControlStateNormal];
    reloadBtn.layer.borderColor = UIColorFromRGB(0xF58667).CGColor;
    reloadBtn.layer.borderWidth = 0.5;
    reloadBtn.layer.cornerRadius = 6.0;
    reloadBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [reloadBtn setTitle:@"重新加载" forState:UIControlStateNormal];
    [reloadBtn addTarget:self.delegate action:@selector(reloadPageAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:reloadBtn];
}

@end
