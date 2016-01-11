//
//  DownSheet.h
//  audioWriting
//
//  Created by wolf on 14-7-19.
//  Copyright (c) 2014年 wangruiyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownSheetCell.h"
@protocol DownSheetDelegate <NSObject>
@optional
- (void)didSelectIndex:(NSInteger)index;

- (void)shouldDismissSheet;

@end

@interface DownSheet : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    UITableView *view;
    NSArray *listData;
    UIButton *dismissBtn;
}
- (id)initWithlist:(NSArray *)list height:(CGFloat)height andTitle:(NSString *)title;

- (void)showInView:(UIViewController *)Sview;

-(void)dismissSheet;

@property(nonatomic,assign) id <DownSheetDelegate> delegate;

@property (nonatomic, copy) NSString *title;

@end

