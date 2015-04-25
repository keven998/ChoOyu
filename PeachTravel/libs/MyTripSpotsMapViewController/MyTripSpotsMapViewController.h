//
//  MyTripSpotsMapViewController.h
//  lvxingpai
//
//  Created by liangpengshuai on 14-7-23.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTripSpotsMapViewController : TZViewController

@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, assign) NSUInteger currentDay;         //标记当前是第几天
@property (nonatomic, copy) NSString *titleText;

@end

@interface SelectPoiCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *textView;

@end