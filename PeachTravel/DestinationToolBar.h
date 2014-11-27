//
//  DestinationToolBar.h
//  PeachTravelDemo
//
//  Created by liangpengshuai on 14/9/24.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DestinationUnit.h"

@protocol DestinationToolBarDelegate <NSObject>

- (void)removeUintCell:(NSInteger)index;

@end

@interface DestinationToolBar : UIView

- (id)initWithFrame:(CGRect)frame andNextBtnTitle:(NSString *)title;

-(void)setHidden:(BOOL)hidden withAnimation:(BOOL)animation;

@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) id<DestinationToolBarDelegate> delegate;

- (void) addNewUnit:(NSString *)icon withName:(NSString *)name;
- (void) addNewUnitWithName:(NSString *)name;
- (void) addNewUnitWithName:(NSString *)name userInteractionEnabled:(BOOL)userInteractionEnabled;
- (DestinationUnit *) addUnit:(NSString *)icon withName:(NSString *)name;

- (void) removeUnitAtIndex:(NSInteger)index;

@end
