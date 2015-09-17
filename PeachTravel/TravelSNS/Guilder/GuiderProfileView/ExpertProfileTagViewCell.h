//
//  ExpertProfileTagViewCell.h
//  PeachTravel
//
//  Created by 王聪 on 15/9/6.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FrendModel;

@interface ExpertProfileTagViewCell : UITableViewCell

@property (nonatomic, strong) FrendModel *userInfo;

@property (nonatomic, strong) NSArray *collectionArray;

+ (id)expertDetailInfo;


@end
