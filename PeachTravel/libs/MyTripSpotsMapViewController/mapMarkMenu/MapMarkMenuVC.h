//
//  MapMarkMenuVC.h
//  MapMark
//
//  Created by 冯宁 on 15/9/24.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapMarkMenuVCDelegate <NSObject>

- (void)selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath;


@end

@interface MapMarkMenuVC : UIView

@property (nonatomic, weak) id <MapMarkMenuVCDelegate> delegate;

- (instancetype)initWithArray:(NSArray*)array;

@end
