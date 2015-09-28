//
//  ItemFooterCollectionViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 7/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemFooterCollectionViewControllerDelegate <NSObject>

- (void)didSelectedItem:(NSInteger)index;

@end

@interface ItemFooterCollectionViewController : UIViewController

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, weak) id <ItemFooterCollectionViewControllerDelegate> delegate;

@end
