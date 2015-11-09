//
//  CityListCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/2/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CityListCollectionViewCell.h"

@implementation CityListCollectionViewCell

- (void)awakeFromNib {
     [_headerImageView sd_setImageWithURL:[NSURL URLWithString:@"http://images.taozilvxing.com/28c2d1ef35c12100e99fecddb63c436a?imageView2/2/w/1200"] placeholderImage:nil];
}

@end
