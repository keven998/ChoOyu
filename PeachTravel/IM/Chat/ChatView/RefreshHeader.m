//
//  RefreshHeader.m
//  PeachTravel
//
//  Created by dapiao on 15/6/25.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "RefreshHeader.h"

@implementation RefreshHeader
#pragma mark - 重写方法
#pragma mark 基本设置
- (void)prepare
{
    [super prepare];
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<15; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Loading_Animation_final%zd.png", i]];
        [idleImages addObject:image];
    }
    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<15; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Loading_Animation_final%zd.png", i]];
        [refreshingImages addObject:image];
    }
    [self setImages:refreshingImages forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
}
@end
