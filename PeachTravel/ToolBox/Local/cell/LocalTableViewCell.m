//
//  LocalTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/3.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "LocalTableViewCell.h"

@implementation LocalTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _contentTypeFlag.clipsToBounds = YES;
    _contentTypeFlag.contentMode = UIViewContentModeScaleAspectFill;
    _address.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _address.titleLabel.numberOfLines = 2;
    
    _commentContent.adjustsFontSizeToFitWidth = NO;

//    _ratingBar.numberOfStar = 5;
//    [_ratingBar setMarkImage:[UIImage imageNamed:@"ic_gender_lady.png"]];
//    [_ratingBar setHighlightColor:[UIColor yellowColor]];
//    [_ratingBar setStepInterval:0.5];
//    [_ratingBar setBaseColor:[UIColor whiteColor]];
//    [_ratingBar setHighlightColor:[UIColor yellowColor]];
//    _ratingBar.userInteractionEnabled = NO;
//    [_ratingBar sizeToFit];
    
    _ratingBar.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingBar.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingBar.maxRating = 5.0;
    _ratingBar.editable = NO;
    _ratingBar.displayMode = EDStarRatingDisplayAccurate;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
