//
//  CommentTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "EDStarRating.h"

@interface CommentTableViewCell ()

@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
    _headerImageView.layer.cornerRadius = CGRectGetWidth(_headerImageView.frame)/2.0;
    
    _ratingView.starImage = [UIImage imageNamed:@"icon_rating_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"icon_rating_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 1;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.userInteractionEnabled = NO;
}

- (void)setCommentDetail:(CommentDetail *)commentDetail
{
    _commentDetail = commentDetail;
    _descLabel.text = _commentDetail.commentDetails;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_commentDetail.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default.png"]];
    _titleLabel.text = [NSString stringWithFormat:@"%@", commentDetail.nickName];
    _timeLabel.text = commentDetail.commentTime;
    [_ratingView setRating:_commentDetail.rating];
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)heightForCommentCellWithComment:(NSString *)commentDetail
{
    CGSize labelSize = [commentDetail boundingRectWithSize:CGSizeMake(kWindowWidth-64, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{
                                                             NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                             }
                                                   context:nil].size;
    return labelSize.height+94;
}

@end








