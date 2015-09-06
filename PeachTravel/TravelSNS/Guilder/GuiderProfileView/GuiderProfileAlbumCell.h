//
//  GuiderProfileAlbumCell.h
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuiderProfileAlbumCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UILabel *titleLab;
@property (nonatomic, weak) UILabel *albumCount;
@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *albumArray;

@property (nonatomic, weak) UIButton *arrowBtn;

@end
