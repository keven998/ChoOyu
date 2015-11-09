//
//  TZTagsCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/7/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "TZTagsCollectionViewCell.h"

@implementation TZTagsCollectionViewCell

- (void)awakeFromNib {
    self.tagLabel.layer.cornerRadius = 4;
    self.tagLabel.layer.borderWidth = 0.5;
}

@end
