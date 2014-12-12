//
//  RecommendsTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiSummary.h"

@interface RecommendsTableViewCell : UITableViewCell<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *recommendCollectionView;

@property (nonatomic, strong) NSArray *recommends;

@property (nonatomic, strong) PoiSummary *poiSummary;

@end
