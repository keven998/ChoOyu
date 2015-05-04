//
//  HeaderPictureCell.h
//  PeachTravel
//
//  Created by dapiao on 15/5/3.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderPictureCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (copy,nonatomic) NSMutableArray *headerPicArray;
@end
