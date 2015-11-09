//
//  CityListCollectionViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/2/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityListCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backgroundMaskImageView;
@property (weak, nonatomic) IBOutlet UILabel *zhNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *enNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *countMaskImageView;
@property (weak, nonatomic) IBOutlet UILabel *sellerCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@end
