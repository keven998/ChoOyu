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
@property (strong, nonatomic) UIImageView *bubbleView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
    _bubbleView = [[UIImageView alloc] init];
    [self addSubview:_bubbleView];
    _descLabel = [[UILabel alloc] init];
    _descLabel.numberOfLines = 0;
    _descLabel.font = [UIFont systemFontOfSize:14.0];
    _descLabel.textColor = COLOR_TEXT_I;
    [_bubbleView addSubview:_descLabel];
    _headerImageView.layer.cornerRadius = CGRectGetWidth(_headerImageView.frame)/2.0;
    
    _titleLabel.textColor = COLOR_TEXT_III;
    
    _ratingView.starImage = [UIImage imageNamed:@"poi_comment_start_default.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"poi_comment_start_highlight.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 2;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
}

- (void)layoutSubviews
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.0;
    CGSize labelSize = [_commentDetail.commentDetails boundingRectWithSize:CGSizeMake(self.bounds.size.width-100-24, MAXFLOAT)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{
                                                                             NSFontAttributeName : [UIFont systemFontOfSize:14.0],
                                                                             NSParagraphStyleAttributeName : style
                                                                             }
                                                                   context:nil].size;
    _descLabel.frame = CGRectMake(15, 13, labelSize.width, labelSize.height);
    
    [_bubbleView setFrame:CGRectMake(84, 38, labelSize.width+25, labelSize.height+26)];
    _bubbleView.image = [[UIImage imageNamed:@"messages_bg_friend.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 15, 10, 10)];
    
    [_ratingView setRating:_commentDetail.rating];
}

- (void)setCommentDetail:(CommentDetail *)commentDetail
{
    _commentDetail = commentDetail;
    _descLabel.text = _commentDetail.commentDetails;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_commentDetail.avatar] placeholderImage:nil];
    _titleLabel.text = [NSString stringWithFormat:@"%@ | %@", commentDetail.nickName, commentDetail.commentTime];
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)heightForCommentCellWithComment:(NSString *)commentDetail
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.0;
    CGSize labelSize = [commentDetail boundingRectWithSize:CGSizeMake(kWindowWidth-100-24, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{
                                                             NSFontAttributeName : [UIFont systemFontOfSize:14.0],
                                                             NSParagraphStyleAttributeName : style
                                                             }
                                                   context:nil].size;
    return labelSize.height+38+30+10;
}

@end








