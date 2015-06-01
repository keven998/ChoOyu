//
//  HeaderPictureCell.h
//  PeachTravel
//
//  Created by dapiao on 15/5/3.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeaderPictureDelegate <NSObject>

- (void)showPickerView;

/**
 *  编辑album
 *
 *  @param index 点击的位置
 */
- (void)editAvatar:(NSInteger)index;



@end

@interface HeaderPictureCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (copy,nonatomic) NSArray *headerPicArray;

@property (weak, nonatomic) id<HeaderPictureDelegate> delegate;

@end
