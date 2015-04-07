//
//  SelectionTableViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 15/4/3.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectDelegate;
@interface SelectionTableViewController : UIViewController

@property (nonatomic, assign) id<SelectDelegate> delegate;

@property (nonatomic, strong) NSArray *contentItems;
@property (nonatomic, strong) NSString *selectItem;
@property (nonatomic, assign) NSInteger selectItemIndex;
@property (nonatomic, strong) NSString *titleTxt;

@end

@protocol SelectDelegate <NSObject>

- (void)selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath;

@end