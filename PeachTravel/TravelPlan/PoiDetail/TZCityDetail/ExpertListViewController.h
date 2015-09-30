//
//  ExpertListViewController.h
//  TZCityDetail
//
//  Created by 冯宁 on 15/9/19.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TZTBViewController.h"
#import "PeachTravel-swift.h"

@interface ExpertListViewController : UIViewController

/**
 *  是搜索游记还是查看城市的游记
 */
@property (nonatomic) BOOL isSearch;

@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *cityName;

@property (nonatomic, copy) NSString* areaId;
@property (nonatomic, copy) NSString* areaName;

@property (nonatomic) NSInteger chatterId;
@property (nonatomic) IMChatType chatType;

/**
 *  是否是达人游记
 */
@property (nonatomic, assign) NSInteger userId;

- (instancetype)initWithCityName:(NSString*)cityName orAreaId:(NSString*)areaId;

@end
