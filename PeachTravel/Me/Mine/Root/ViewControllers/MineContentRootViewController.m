//
//  MineContentRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/1/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "MineContentRootViewController.h"

@interface MineContentRootViewController ()

//保存 切换按钮
@property (nonatomic, strong) NSArray *segmentBtns;

//保存 切换按钮标题
@property (nonatomic, strong) NSArray *segmentTitles;

//保存 切换按钮常态图片
@property (nonatomic, strong) NSArray *segmentNormalImages;

//保存 切换按钮选中态图片
@property (nonatomic, strong) NSArray *segmentSelectedImages;

//保存 包含的 controller
@property (nonatomic, strong) NSArray *contentControllers;

@end

@implementation MineContentRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _segmentTitles = @[@"旅行计划", @"联系人"];
    [self setupSegmentView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - setter & getter


#pragma mark - private methods

/**
 *  初始化切换按钮
 */
- (void)setupSegmentView
{
    UIView *segmentPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 49)];
    [self.view addSubview:segmentPanel];
    
    NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
    
    float btnWidth = self.view.bounds.size.width/[_segmentTitles count];
    float btnHeight = 49;
    float offsetX = 0;
    for (int i = 0; i < [_segmentTitles count]; i++) {
        NSString *title = [_segmentTitles objectAtIndex:i];
        NSString *imageNormalName = [_segmentNormalImages objectAtIndex:i];
        NSString *imageSelectName = [_segmentSelectedImages objectAtIndex:i];
        UIButton *segmentBtn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 0, btnWidth, btnHeight)];
        [segmentBtn setTitle:title forState:UIControlStateNormal];
        [segmentBtn setImage:[UIImage imageNamed:imageNormalName] forState:UIControlStateNormal];
        [segmentBtn setImage:[UIImage imageNamed:imageSelectName] forState:UIControlStateSelected];
        [segmentBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        [segmentBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateSelected];
        [segmentPanel addSubview:segmentBtn];
        [buttonArray addObject:segmentBtn];
        offsetX += btnWidth;
    }
    _segmentBtns = buttonArray;
}

- (void)changePage:(NSUInteger)pageIndex
{
    NSLog(@"切换到第 %ld", pageIndex);
}

#pragma mark - IBAction methods

- (void)changePageAction:(UIButton *)sender
{
    NSInteger index = [_segmentBtns indexOfObject:sender];
    [self changePage:index];
}

@end
