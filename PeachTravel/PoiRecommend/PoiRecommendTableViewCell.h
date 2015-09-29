//
//  PoiRecommendTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/24/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiRecommend.h"

@interface PoiRecommendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (nonatomic, strong) PoiRecommend *poi;

@end
