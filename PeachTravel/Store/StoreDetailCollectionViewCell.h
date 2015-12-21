//
//  StoreDetailCollectionViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailModel.h"

@interface StoreDetailCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *saleCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;

@end
