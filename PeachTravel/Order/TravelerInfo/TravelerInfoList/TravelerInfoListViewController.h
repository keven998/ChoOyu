//
//  TravelerInfoListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/10/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTravelerInfoModel.h"

@protocol TravelerInfoListDelegate<NSObject>

@optional
- (void)finishSelectTraveler:(NSArray<OrderTravelerInfoModel *> *)travelerList;

@end

@interface TravelerInfoListViewController : TZViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) id<TravelerInfoListDelegate>delegate;

@property (nonatomic, strong) NSMutableArray<OrderTravelerInfoModel *> *selectedTravelers;   //选中的联系人


@end
