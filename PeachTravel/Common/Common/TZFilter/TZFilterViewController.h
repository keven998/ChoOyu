//
//  TZFilterViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZFilterView.h"

@protocol TZFilterViewDelegate <NSObject>

- (void)didSelectedItems:(NSArray *)itemIndexPath;

@end

@interface TZFilterViewController : UIViewController
/**
 *  储存选中 item 的 indexpath
 */
@property (nonatomic, strong) NSArray *selectedItmesIndex;

/**
 *  显示筛选面板
 */
- (void)showFilterViewInViewController:(UIViewController *)parentViewController;

/**
 *  隐藏筛选面板
 */
- (void)hideFilterView;

/**
 *  储存筛选按钮标题的数组
 */
@property (nonatomic, strong) NSArray *filterItemsArray;

/**
 *  每个分类的筛选有多少行
 */
@property (nonatomic, strong) NSArray *lineCountPerFilterType;

/**
 * 每组筛选的标题
 */
@property (nonatomic, strong) NSArray *filterTitles;

@property (nonatomic) BOOL filterViewIsShowing;

@property (nonatomic, weak) id <TZFilterViewDelegate>delegate;

@end
