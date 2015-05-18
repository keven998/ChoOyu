//
//  OthersAlbumCell.h
//  PeachTravel
//
//  Created by dapiao on 15/5/18.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OthersAlbumCell : UITableViewCell

@property (copy,nonatomic) NSMutableArray *headerPicArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
