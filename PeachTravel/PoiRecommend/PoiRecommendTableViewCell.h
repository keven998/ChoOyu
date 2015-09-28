//
//  PoiRecommendTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/24/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoiRecommendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;

@property (nonatomic, strong) SuperPoi *poi;

@end
