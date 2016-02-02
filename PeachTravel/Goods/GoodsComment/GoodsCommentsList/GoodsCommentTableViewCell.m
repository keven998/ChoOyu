//
//  GoodsCommentTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/1/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsCommentTableViewCell.h"
#import "PeachTravel-swift.h"
#import "GoodsDetailModel.h"

@implementation GoodsCommentTableViewCell


+ (CGFloat)heightWithCommentDetail:(GoodsCommentDetail *)comment
{
    CGFloat retHeight = 58;
    if (comment.contents) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:comment.contents attributes:attribs];
        
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-65, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        retHeight += rect.size.height;
    }
    
    retHeight += 38;
    
    return retHeight;
    
}

- (void)awakeFromNib {
    _avatarImageView.layer.cornerRadius = 17.5;
    _avatarImageView.clipsToBounds = YES;
    
    _ratingView.starImage = [UIImage imageNamed:@"icon_rating_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"icon_rating_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 1;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.userInteractionEnabled = NO;
    
    _timeLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setGoodsComment:(GoodsCommentDetail *)goodsComment
{
    _goodsComment = goodsComment;
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_goodsComment.commentUser.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    _nickNameLabel.text = _goodsComment.commentUser.nickName;
    _timeLabel.text = _goodsComment.publishTime;
    _ratingView.rating = _goodsComment.rating*5;
    _goodsPackageLabel.text = _goodsComment.selectedPackage.packageName;
    if (_goodsComment.contents) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:_goodsComment.contents attributes:attribs];
        _contentsLabel.attributedText = attrstr;
    }
}

@end
