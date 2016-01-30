//
//  GoodsListTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/6/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZTagsCollectionView.h"
#import "GoodsDetailModel.h"
#import "EDStarRating.h"

@interface GoodsListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *storeNameBtn;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *saleCountLabel;

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;

@end
