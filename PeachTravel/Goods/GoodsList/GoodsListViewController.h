//
//  GoodsListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/6/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet TZButton *categoryBtn;
@property (weak, nonatomic) IBOutlet TZButton *sortBtn;

@property (nonatomic, copy) NSString *cityId;

@end
