//
//  PoisOfCityViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityPoi.h"
#import "TripDetail.h"

@protocol PoisOfCityDelegate <NSObject>

- (void)finishEdit;

@end

@interface PoisOfCityViewController : UIViewController

@property (nonatomic, copy) NSString *cityId; //当前显示的城市
@property (nonatomic, copy) NSString *zhName; //当前显示的城市
@property (nonatomic, copy) NSString *descDetail;

/**
 *  标记是从三账单进来的还是从从城市详情界面进来的
 */
@property (nonatomic) BOOL shouldEdit;
@property (nonatomic, strong) TripDetail *tripDetail;
@property (nonatomic) TZPoiType poiType;
//如果从三张单进来的话，记录选择的 poi
@property (nonatomic, strong) NSMutableArray *selectedArray;


/**
 *  标识这个界面加载的数据
 */
@property (nonatomic, assign)NSInteger page;

@property (nonatomic, weak) id <PoisOfCityDelegate>delegate;

@end

@interface SelectDestCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *deleteBtn;

@end
