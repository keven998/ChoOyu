//
//  ExpertCollectionCell.h
//  PeachTravel
//
//  Created by 王聪 on 9/10/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaoziCollectionLayout.h"
@class ExpertModel;

@interface ExpertCollectionCell : UICollectionViewCell <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TaoziLayoutDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *city;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIButton *levelBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) ExpertModel *guiderModel;
@property (nonatomic, strong) NSArray *collectionArray;


@end
