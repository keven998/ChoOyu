//
//  HeaderCell.h
//  PeachTravel
//
//  Created by dapiao on 15/4/30.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (assign, nonatomic) CGFloat h;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (copy,nonatomic) NSArray *dataArray;
@end
