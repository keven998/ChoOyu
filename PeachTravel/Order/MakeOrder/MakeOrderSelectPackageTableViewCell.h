//
//  MakeOrderSelectPackageTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsPackageModel.h"

@protocol MakeOrderSelectPackageDelegate <NSObject>

/**
 *  选中了哪个 package
 *
 *  @param package 选中 package
 */

@optional
- (void)didSelectedPackage:(GoodsPackageModel *)package;

@end

@interface MakeOrderSelectPackageTableViewCell : UITableViewCell <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray <GoodsPackageModel *> *packageList;

@property (nonatomic, weak) id<MakeOrderSelectPackageDelegate>deleagte;

+ (CGFloat)heightWithPackageCount:(int)count;

@end
