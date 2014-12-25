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

@property (weak, nonatomic) IBOutlet UIButton *nickNameBtn;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
}

- (void)setCommentDetail:(CommentDetail *)commentDetail
{
    _commentDetail = commentDetail;
    CGSize size = [_commentDetail.commentDetails sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:11]}];
    NSInteger lineCount = (size.width / (self.frame.size.width-60)) + 1;
    _descLabel.numberOfLines = lineCount;
    
    _descLabel.text = commentDetail.commentDetails;
    [_nickNameBtn setTitle:commentDetail.nickName forState:UIControlStateNormal];
    _dateLabel.text = _commentDetail.commentTime;
    

    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
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
    CGSize size = [commentDetail sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:11.0]}];
    NSInteger lineCount = (size.width / (kWindowWidth-16)) + 1;
    CGFloat commentHeight = lineCount*size.height+10;
    return commentHeight+60;
}

@end
