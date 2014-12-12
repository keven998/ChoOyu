//
//  TZTBViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 14/12/12.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZTBViewController : UIViewController

//loading more status
@property (nonatomic, assign) BOOL isLoadingMore;

//TODO
@property (nonatomic, assign) BOOL enableLoadingMore;

//The view used for loading more
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UITableView *tableView;

// Called when all the conditions are met and -loadMore will begin.
- (void) beginLoadingMore;

// Call to signal that "load more" was completed.
- (void) loadMoreCompleted;

// Helper to show/hide -footerView
- (void) setFooterViewVisibility:(BOOL)visible;

@end
