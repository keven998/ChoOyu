//
//  CityHeaderView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityHeaderView : UIView

@property (nonatomic, copy) NSString *cityImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic) double timeCost;
@property (nonatomic, copy) NSString *travelMonth;

@property (weak, nonatomic) IBOutlet UIButton *shoppingBtn;
@property (weak, nonatomic) IBOutlet UIButton *restaurantBtn;
@property (weak, nonatomic) IBOutlet UIButton *spotBtn;
+(CityHeaderView *)instanceHeaderView;

@end
