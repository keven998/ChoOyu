//
//  RestaurantOfCityTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantOfCityTableViewCell.h"
#import "CommentDetail.h"

@interface RestaurantOfCityTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *HeaderImageView;
@property (weak, nonatomic) IBOutlet UIButton *ratingBtn;
@property (weak, nonatomic) IBOutlet UIButton *addressBtn;
@property (weak, nonatomic) IBOutlet UILabel *commentAuthor;
@property (weak, nonatomic) IBOutlet UILabel *commentDetail;
@property (weak, nonatomic) IBOutlet UIButton *commentCntBtn;


@end

@implementation RestaurantOfCityTableViewCell

- (void)setRestaurantPoi:(RestaurantPoi *)restaurantPoi
{
    _restaurantPoi = restaurantPoi;
    [_titleBtn setTitle:_restaurantPoi.zhName forState:UIControlStateNormal];
    _priceLabel.text = _restaurantPoi.priceDesc;
    TaoziImage *image = [_restaurantPoi.images firstObject];
    [_HeaderImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    [_addressBtn setTitle:_restaurantPoi.address forState:UIControlStateNormal];
    _addressBtn.titleLabel.numberOfLines = 2;
    if (restaurantPoi.comments.count) {
        _commentDetail.hidden = NO;
        _commentAuthor.hidden = NO;
        _commentCntBtn.hidden = NO;
        CommentDetail *comment = [restaurantPoi.comments firstObject];
        _commentAuthor.text = comment.nickName;
        _commentDetail.text = comment.commentDetails;
        [_commentCntBtn setTitle:[NSString stringWithFormat:@"%d条",restaurantPoi.commentCount]  forState:UIControlStateNormal];
    } else {
        _commentDetail.hidden = YES;
        _commentAuthor.hidden = YES;
        _commentCntBtn.hidden = YES;
    }
    
}

@end
