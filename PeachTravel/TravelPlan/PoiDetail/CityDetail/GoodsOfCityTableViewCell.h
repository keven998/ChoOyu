//
//  GoodsOfCityTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/5/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeachTravel-Swift.h"
#import "GoodsDetailModel.h"

@interface GoodsOfCityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIView *avatarBkgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *ratingBtn;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;

@end
