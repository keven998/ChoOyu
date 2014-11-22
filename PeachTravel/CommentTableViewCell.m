//
//  CommentTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CommentTableViewCell.h"

@interface CommentTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *nickNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *ratingBtn;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
}

- (void)setCommentDetail:(CommentDetail *)commentDetail
{
    _commentDetail = commentDetail;
    CGSize size = [_commentDetail.commentDetails sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15]}];
    NSInteger lineCount = (size.width / (self.frame.size.width-60)) + 1;
    _descLabel.numberOfLines = lineCount;
    _descLabel.text = commentDetail.commentDetails;
    [_nickNameBtn setTitle:commentDetail.nickName forState:UIControlStateNormal];
    _dateLabel.text = _commentDetail.commentTime;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
