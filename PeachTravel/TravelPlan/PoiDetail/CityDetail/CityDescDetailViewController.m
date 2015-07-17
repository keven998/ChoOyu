//
//  CityDescDetailViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/5/11.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "CityDescDetailViewController.h"
#import "UIBarButtonItem+MJ.h"


@interface CityDescDetailViewController ()

@end

@implementation CityDescDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_icon_navigaiton_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    
    UILabel * desLabel = [[UILabel alloc]init];
    desLabel.numberOfLines = 0;
    desLabel.textColor = COLOR_TEXT_I;
    [scrollView addSubview:desLabel];
    
    CGRect frame = CGRectMake(10, 10, CGRectGetWidth(self.view.bounds) - 20, 0);
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 5.0;
    ps.paragraphSpacing = 20.0;
    ps.firstLineHeadIndent = 32.0;
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:ps};
    NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:self.des attributes:attribs];
    CGRect rect = [attrstr boundingRectWithSize:(CGSize){CGRectGetWidth(frame), CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    frame.size.height = ceilf(rect.size.height) + 1;
    desLabel.frame = frame;
    desLabel.attributedText = attrstr;
    
    scrollView.contentSize = CGSizeMake(0, rect.size.height + 24);
}
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
