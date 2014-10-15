//
//  AboutController.m
//  fanny
//
//  Created by Luo Yong on 13-6-7.
//  Copyright (c) 2013年 shinro. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AboutViewController.h"
#import "AppUtils.h"

@interface AboutController ()

@end

@implementation AboutController

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"关于";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = self.view.frame.size.width;
    
    CGFloat offsetY = 32.;
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake((width - 60.0)/2, offsetY, 60.0, 60.0)];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.image = [UIImage imageNamed:@"about_icon.png"];
    CALayer *layer = [logo layer];
    layer.shadowColor = [UIColor colorWithWhite:0. alpha:0.5].CGColor;
    layer.shadowOffset = CGSizeMake(0, 2.0);
    layer.shadowOpacity = 0.8;
    layer.shadowRadius = 2.0;
    [self.view addSubview:logo];
    
    offsetY += 60. + 8.;
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, offsetY, width, 22.0)];
    title.font = [UIFont systemFontOfSize:20.0];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = UIColorFromRGB(0x5a5a5a);
    title.text = @"桃子旅行";
    [self.view addSubview:title];
    
    offsetY += 20. + 64.;
    
    UILabel *title1 = [[UILabel alloc]initWithFrame:CGRectMake(40.0, offsetY, width - 50., 20.0)];
    title1.font = [UIFont systemFontOfSize:18.0];
    title1.backgroundColor = [UIColor clearColor];
    title1.textColor = UIColorFromRGB(0x313131);
    title1.text = @"关注我们";
    [self.view addSubview:title1];
    offsetY += 22.;
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, 110, 0.5)];
    divider.backgroundColor = UIColorFromRGB(0xc8cbd0);
    [self.view addSubview:divider];
    
    offsetY += 15.;
    
    UILabel *net = [[UILabel alloc] initWithFrame:CGRectMake(40., offsetY, width - 50., 15.)];
    net.font = [UIFont systemFontOfSize:13.];
    net.textColor = UIColorFromRGB(0x313131);
    net.text = @"网站: http://www.lvxingpai.com";
    [self.view addSubview:net];
    
    offsetY += 23.;
    UILabel *weichat = [[UILabel alloc]initWithFrame:CGRectMake(40., offsetY, width - 50., 15.)];
    weichat.font = [UIFont systemFontOfSize:13.];
    weichat.backgroundColor = [UIColor clearColor];
    weichat.textColor = UIColorFromRGB(0x313131);
    weichat.text = @"微信: 桃子旅行";
    [self.view addSubview:weichat];
    
    offsetY += 23.;
    UILabel *weibo = [[UILabel alloc]initWithFrame:CGRectMake(40., offsetY, width - 50., 15.)];
    weibo.font = [UIFont systemFontOfSize:13.];
    weibo.backgroundColor = [UIColor clearColor];
    weibo.textColor = UIColorFromRGB(0x313131);
    weibo.text = @"微博: 桃子旅行";
    [self.view addSubview:weibo];
    
    offsetY += 23.;
    UILabel *email = [[UILabel alloc]initWithFrame:CGRectMake(40., offsetY, width - 50., 15.)];
    email.font = [UIFont systemFontOfSize:13.];
    email.backgroundColor = [UIColor clearColor];
    email.textColor = UIColorFromRGB(0x313131);
    email.text = @"邮箱: services@lvxingpai.cn";
    [self.view addSubview:email];
    
    offsetY += 23.;
    UILabel *qq = [[UILabel alloc]initWithFrame:CGRectMake(40., offsetY, width - 50., 15.)];
    qq.font = [UIFont systemFontOfSize:13.];
    qq.backgroundColor = [UIColor clearColor];
    qq.textColor = UIColorFromRGB(0x313131);
    qq.text = @"QQ群: 45742544";
    [self.view addSubview:qq];
    
    UILabel *about = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 104., width, 40.)];
    about.numberOfLines = 0;
    about.adjustsFontSizeToFitWidth = YES;
    about.font = [UIFont systemFontOfSize:13.];
    about.textColor = UIColorFromRGB(0x313131);
    about.text = @"爱走天下网络科技有限责任公司\n版权所有";
    about.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:about];
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 68., width, 20.)];
    version.font = [UIFont systemFontOfSize:13.];
    version.textColor = UIColorFromRGB(0x666666);
    AppUtils *utils = [[AppUtils alloc] init];
    version.text = utils.appVersion;
    version.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:version];
    
    UILabel *right = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 53., width, 20.)];
    right.numberOfLines = 0;
    right.adjustsFontSizeToFitWidth = YES;
    right.font = [UIFont systemFontOfSize:9.];
    right.textColor = UIColorFromRGB(0x313131);
    right.text = @"All Rights Reserved.";
    right.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:right];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
