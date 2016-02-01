//
//  GoodsCommentTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 2/1/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsCommentDetail.h"
#import "EDStarRating.h"

@interface GoodsCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsPackageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) GoodsCommentDetail *goodsComment;

+ (CGFloat)heightWithCommentDetail:(GoodsCommentDetail *)comment;

@end
