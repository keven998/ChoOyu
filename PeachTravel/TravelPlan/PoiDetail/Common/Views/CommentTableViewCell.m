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
@property (weak, nonatomic) IBOutlet UIImageView *bubbleView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
    _descLabel = [[UILabel alloc] init];
    _descLabel.numberOfLines = 0;
    _descLabel.font = [UIFont systemFontOfSize:11.0];
    [_bubbleView addSubview:_descLabel];
}

- (void)setCommentDetail:(CommentDetail *)commentDetail
{
    _commentDetail = commentDetail;
    _descLabel.text = _commentDetail.commentDetails;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_commentDetail.avatar] placeholderImage:nil];
    _titleLabel.text = commentDetail.nickName;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 1.0;
    
    CGSize labelSize = [_commentDetail.commentDetails boundingRectWithSize:CGSizeMake(self.bounds.size.width-100-24, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{
                                                             NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                             NSParagraphStyleAttributeName : style
                                                             }
                                                   context:nil].size;
    
//    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y
//                              , self.frame.size.width, labelSize.height)];
    
    _descLabel.frame = CGRectMake(15, 13, labelSize.width, labelSize.height);
    
    [_bubbleView setFrame:CGRectMake(80, 30, labelSize.width+25, labelSize.height+26)];
    _bubbleView.image = [[UIImage imageNamed:@"messages_bg_friend.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 15, 10, 10)];

    
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"ic_star_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    [_ratingView setRating:commentDetail.rating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)heightForCommentCellWithComment:(NSString *)commentDetail
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 1.0;
    
    CGSize labelSize = [commentDetail boundingRectWithSize:CGSizeMake(kWindowWidth-100-24, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                        NSParagraphStyleAttributeName : style
                                                        }
                                              context:nil].size;
    return labelSize.height+26+30+10;
}

@end








