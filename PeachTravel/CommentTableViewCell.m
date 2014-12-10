//
//  CommentTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "AXRatingView.h"

@interface CommentTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *nickNameBtn;
@property (weak, nonatomic) IBOutlet AXRatingView *ratingView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
}

- (void)setCommentDetail:(CommentDetail *)commentDetail
{
    _commentDetail = commentDetail;
_commentDetail.commentDetails =@"sdklfjsdlfjsdds离开家法拉克减肥撒龙卷风快上课了打飞机塞德里克福建师大";
    CGSize size = [_commentDetail.commentDetails sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:11]}];
    NSInteger lineCount = (size.width / (self.frame.size.width-60)) + 1;
    _descLabel.numberOfLines = lineCount;
    
    _descLabel.text = commentDetail.commentDetails;
    [_nickNameBtn setTitle:commentDetail.nickName forState:UIControlStateNormal];
    _dateLabel.text = _commentDetail.commentTime;
    _ratingView.userInteractionEnabled = NO;
    _ratingView.markImage = [UIImage imageNamed:@"ic_star_gray.png"];
    [_ratingView sizeToFit];
    _ratingView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _ratingView.value  = commentDetail.rating;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
