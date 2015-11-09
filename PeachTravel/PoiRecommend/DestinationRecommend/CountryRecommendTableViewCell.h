//
//  CountryRecommendTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/5/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryRecommendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@property (weak, nonatomic) IBOutlet UILabel *zhNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *enNameLabel;
@end
