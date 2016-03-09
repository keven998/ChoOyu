//
//  BNOrderListRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNOrderListRootViewController.h"
#import "DKTabPageViewController.h"
#import "BNOrderListViewController.h"

@interface BNOrderListRootViewController () <DKTabPageViewControllerDelegate>

@end

@implementation BNOrderListRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"我的订单";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *titleArray = @[@"待发货", @"待退款", @"全部"];
   
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:titleArray.count];
    for (int i = 0; i < titleArray.count; i++) {
        BNOrderListViewController *vc = [[BNOrderListViewController alloc] init];
        DKTabPageItem *item = [DKTabPageViewControllerItem tabPageItemWithTitle:titleArray[i]
                                                                 viewController:vc];
        [items addObject:item];
    }
    
    DKTabPageViewController *tabPageViewController = [[DKTabPageViewController alloc] initWithItems:items];
    tabPageViewController.view.backgroundColor = APP_PAGE_COLOR;
    tabPageViewController.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64);
    tabPageViewController.tabPageBar.selectionIndicatorView.hidden = YES;
    tabPageViewController.tabPageBar.selectedTitleColor = UIColorFromRGB(0xFC4E27);
    tabPageViewController.tabPageBar.tabBarHeight = 48;
    tabPageViewController.delegate = self;
    [self addChildViewController:tabPageViewController];
    [self.view addSubview:tabPageViewController.view];
    
    [tabPageViewController setTabPageBarAnimationBlock:^(DKTabPageViewController *weakTabPageViewController, UIButton *fromButton, UIButton *toButton, CGFloat progress) {
        
        // animated font
        CGFloat pointSize = weakTabPageViewController.tabPageBar.titleFont.pointSize;
        CGFloat selectedPointSize = 16;
        
        fromButton.titleLabel.font = [UIFont systemFontOfSize:pointSize + (selectedPointSize - pointSize) * (1 - progress)];
        toButton.titleLabel.font = [UIFont systemFontOfSize:pointSize + (selectedPointSize - pointSize) * progress];
        
        // animated text color
        CGFloat red, green, blue;
        [weakTabPageViewController.tabPageBar.titleColor getRed:&red green:&green blue:&blue alpha:NULL];
        
        CGFloat selectedRed, selectedGreen, selectedBlue;
        [weakTabPageViewController.tabPageBar.selectedTitleColor getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:NULL];
        
        [fromButton setTitleColor:[UIColor colorWithRed:red + (selectedRed - red) * (1 - progress)
                                                  green:green + (selectedGreen - green) * (1 - progress)
                                                   blue: blue + (selectedBlue - blue) * (1 - progress)
                                                  alpha:1] forState:UIControlStateSelected];
        
        [toButton setTitleColor:[UIColor colorWithRed:red + (selectedRed - red) * progress
                                                green:green + (selectedGreen - green) * progress
                                                 blue:blue + (selectedBlue - blue) * progress
                                                alpha:1] forState:UIControlStateNormal];
    }];
    
    CGFloat widthPerItem = self.view.bounds.size.width/items.count;
    for (int i=0; i<items.count-1; i++) {
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(widthPerItem*(i+1), 9, 0.5, 30)];
        spaceView.backgroundColor = COLOR_LINE;
        [tabPageViewController.view addSubview:spaceView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
