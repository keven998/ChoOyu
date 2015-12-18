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

- (void)finishSelectTravelers:(NSArray<OrderTravelerInfoModel *> *)travelerList;

- (void)finishSelectTraveler:(OrderTravelerInfoModel *)selectTraveler;

@end

@interface SelectTravelerListViewController : TZViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//是否可以多选
@property (nonatomic) BOOL canMultipleSelect;

//是否可以编辑
@property (nonatomic) BOOL canEditInfo;

@property (nonatomic, weak) id<TravelerInfoListDelegate>delegate;

@property (nonatomic, strong) NSMutableArray<OrderTravelerInfoModel *> *selectedTravelers;   //选中的联系人


@end
