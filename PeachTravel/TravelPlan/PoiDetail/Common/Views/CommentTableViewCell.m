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
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 1.0;
    
    CGSize labelSize = [_commentDetail.commentDetails boundingRectWithSize:CGSizeMake(kWindowWidth-18-22, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{
                                                             NSFontAttributeName : [UIFont fontWithName:@"MicrosoftYaHei" size:11.0],
                                                             NSParagraphStyleAttributeName : style
                                                             }
                                                   context:nil].size;
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y
                              , self.frame.size.width, labelSize.height)];
    
    _descLabel.text = commentDetail.commentDetails;
    [_nickNameBtn setTitle:commentDetail.nickName forState:UIControlStateNormal];
    _dateLabel.text = _commentDetail.commentTime;
    
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
    
    CGSize labelSize = [commentDetail boundingRectWithSize:CGSizeMake(kWindowWidth-18-22, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : [UIFont fontWithName:@"MicrosoftYaHei" size:11.0],
                                                        NSParagraphStyleAttributeName : style
                                                        }
                                              context:nil].size;
    return labelSize.height+70;
}

@end
