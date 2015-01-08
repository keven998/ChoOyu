//
//  PoisOfCityTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoisOfCityTableViewCell.h"
#import "CommentDetail.h"
#import "EDStarRating.h"

@interface PoisOfCityTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *HeaderImageView;
@property (weak, nonatomic) IBOutlet UIButton *addressBtn;
@property (weak, nonatomic) IBOutlet UILabel *commentAuthor;
@property (weak, nonatomic) IBOutlet UILabel *commentDetail;
@property (weak, nonatomic) IBOutlet UIImageView *spaceView;
@property (weak, nonatomic) IBOutlet UIView *ratingBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;

@end

@implementation PoisOfCityTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _ratingBackgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _distanceLabel.hidden = YES;
    _HeaderImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _HeaderImageView.layer.borderWidth = 0.5;
    _HeaderImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    self.contentView.backgroundColor = APP_PAGE_COLOR;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setPoi:(PoiSummary *)poi
{
    _poi = poi;
    [_titleBtn setTitle:_poi.zhName forState:UIControlStateNormal];
    _priceLabel.text = _poi.priceDesc;
    TaoziImage *image = [_poi.images firstObject];
    [_HeaderImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    [_addressBtn setTitle:_poi.address forState:UIControlStateNormal];
    _addressBtn.titleLabel.numberOfLines = 2;
    _priceLabel.text = _poi.priceDesc;
    _ratingView.rating = _poi.rating;
    [_addressBtn setTitle:_poi.address forState:UIControlStateNormal];
    if (_poi.distanceStr) {
        _distanceLabel.hidden = NO;
        _distanceLabel.text = _poi.distanceStr;
    } else {
        _distanceLabel.hidden = YES;
    }
    if (poi.comments.count) {
        _commentDetail.hidden = NO;
        _commentAuthor.hidden = NO;
        _jumpCommentBtn.hidden = NO;
        CommentDetail *comment = [poi.comments firstObject];
        _commentAuthor.text = comment.nickName;
        _commentDetail.text = comment.commentDetails;
        _spaceView.hidden = NO;
    } else {
        _commentDetail.hidden = YES;
        _commentAuthor.hidden = YES;
        _jumpCommentBtn.hidden = YES;
        _spaceView.hidden = YES;
    }
}

- (void)setShouldEdit:(BOOL)shouldEdit
{
    _shouldEdit = shouldEdit;

    if (_shouldEdit) {
        _actionBtn.backgroundColor = APP_THEME_COLOR;
        [_actionBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_actionBtn setImage:nil forState:UIControlStateNormal];
        [_actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    } else {
        _actionBtn.backgroundColor = [UIColor whiteColor];
        [_actionBtn setTitle:nil forState:UIControlStateNormal];
        [_actionBtn setImage:[UIImage imageNamed:@"ic_navigation_normal.png"] forState:UIControlStateNormal];
        [_actionBtn setImage:[UIImage imageNamed:@"ic_navigation_highlight.png"] forState:UIControlStateHighlighted];
    }
}

- (void)setIsAdded:(BOOL)isAdded
{
    _isAdded = isAdded;
    if (_isAdded) {
        [_actionBtn setTitle:@"已添加" forState:UIControlStateNormal];
        _actionBtn.backgroundColor = [UIColor grayColor];
    } else {
        _actionBtn.backgroundColor = APP_THEME_COLOR;
        [_actionBtn setTitle:@"添加" forState:UIControlStateNormal];
    }
}


@end
