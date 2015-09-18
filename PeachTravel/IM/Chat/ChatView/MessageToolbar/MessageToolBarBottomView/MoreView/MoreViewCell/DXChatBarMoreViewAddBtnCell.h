//
//  DXChatBarMoreViewAddBtnCell.h
//  PeachTravel
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXChatBarMoreViewAddBtnCellDelegate <NSObject>

@required
- (void)CellClickEventWithTag:(NSInteger)tag;

@end

@interface DXChatBarMoreViewAddBtnCell : UICollectionViewCell

@property (nonatomic, strong) NSDictionary* data;
@property (nonatomic, weak) id <DXChatBarMoreViewAddBtnCellDelegate> delegate;

@end
