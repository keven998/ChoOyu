//
//  MineContentRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/1/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "MineContentRootViewController.h"

@interface MineContentRootViewController ()

@end

#define segmentTitles @[@"旅行计划", @"联系人"]
#define segmentNormalImages @[@"", @""]
#define segmentSelectedImages @[@"", @""]


@implementation MineContentRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods

/**
 *  初始化切换按钮
 */
- (void)setupSegmentView
{
    UIView *segmentPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 49)];
    [self.view addSubview:segmentPanel];
    
    float btnWidth = self.view.bounds.size.width/[segmentTitles count];
    float btnHeight = 49;
    float offsetX = 0;
    for (int i = 0; i < [segmentTitles count]; i++) {
        NSString *title = [segmentTitles objectAtIndex:i];
        NSString *imageNormalName = [segmentNormalImages objectAtIndex:i];
        NSString *imageSelectName = [segmentSelectedImages objectAtIndex:i];
        UIButton *segmentBtn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 0, btnWidth, btnHeight)];
        [segmentBtn setTitle:title forState:UIControlStateNormal];
        [segmentBtn setImage:[UIImage imageNamed:imageNormalName] forState:UIControlStateNormal];
        [segmentBtn setImage:[UIImage imageNamed:imageSelectName] forState:UIControlStateSelected];
        [segmentBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        [segmentBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateSelected];
        [segmentPanel addSubview:segmentBtn];
    }
}

@end
