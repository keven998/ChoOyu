//
//  SearchResultTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SearchResultTableViewCell.h"
#import "FrendListTagCell.h"
#import "TaoziCollectionLayout.h"

@implementation SearchResultTableViewCell

- (void)awakeFromNib
{
    self.headerImageView.layer.cornerRadius = 2.0;
    self.headerImageView.clipsToBounds = YES;
    
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _sendBtn.layer.cornerRadius = 2.0;
    _sendBtn.backgroundColor = APP_THEME_COLOR;
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(15.0, CGRectGetHeight(self.frame) - 0.6, CGRectGetWidth(self.frame), 0.6)];
    divider.backgroundColor = COLOR_LINE;
    divider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:divider];
    
    /** @property (nonatomic,strong) EDImage *starHighlightedImage;
     @property (nonatomic,strong) EDImage *starImage;
     @property (nonatomic) NSInteger maxRating;
     @property (nonatomic) float rating; */
    _ratingView.starImage = [UIImage imageNamed:@"poi_bottom_star_default"];
    
    // 设置评分的图片
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"poi_bottom_star_selected"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 2;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    
}

- (void)setIsCanSend:(BOOL)isCanSend
{
    _isCanSend = isCanSend;
    if (_isCanSend) {
        _sendBtn.hidden = NO;
    } else {
        _sendBtn.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
