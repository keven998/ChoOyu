//
//  FootprintViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 15/5/22.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TraceViewController : UIViewController

@property (nonatomic, strong) NSArray* citys;

@end

@interface CityCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *textView;

@end