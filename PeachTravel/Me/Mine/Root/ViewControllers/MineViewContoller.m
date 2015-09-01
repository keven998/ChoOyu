//
//  MineViewContoller.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/1.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "MineViewContoller.h"

@interface MineViewContoller () <UIScrollViewDelegate>
{
    CGFloat contentOffsetY;
    CGFloat oldContentOffsetY;
    CGFloat newContentOffsetY;
}

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation MineViewContoller

#pragma mark - lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupMainView];
}

// 设置scrollView
- (void)setupMainView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor grayColor];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
}

#pragma mark - UIScrollViewDelegate
//开始拖拽视图

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    contentOffsetY = scrollView.contentOffset.y;
}

// 滚动时调用此方法(手指离开屏幕后)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    newContentOffsetY = scrollView.contentOffset.y;
    
    if (newContentOffsetY > oldContentOffsetY && oldContentOffsetY > contentOffsetY) {  // 向上滚动
        NSLog(@"up");
      
    } else if (newContentOffsetY < oldContentOffsetY && oldContentOffsetY < contentOffsetY) { // 向下滚动
        NSLog(@"down");
        
    } else {
        NSLog(@"dragging");
        
    }
    if (scrollView.dragging) {  // 拖拽

        NSLog(@"scrollView.dragging");

        NSLog(@"contentOffsetY: %f", contentOffsetY);
        
        NSLog(@"newContentOffsetY: %f", scrollView.contentOffset.y);
        
        if ((scrollView.contentOffset.y - contentOffsetY) > 5.0f) {  // 向上拖拽
            
            // 隐藏导航栏和选项栏
            
        } else if ((contentOffsetY - scrollView.contentOffset.y) > 5.0f) {   // 向下拖拽
  
        } else {
  
        }
        
    }
    

    
}


// 完成拖拽(滚动停止时调用此方法，手指离开屏幕前)
 - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
 {
 // NSLog(@"scrollViewDidEndDragging");
 
 oldContentOffsetY = scrollView.contentOffset.y;
 
 }
 

@end
