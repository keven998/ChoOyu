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

@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) id<DestinationToolBarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andNextBtnTitle:(NSString *)title;
-(void)setHidden:(BOOL)hidden withAnimation:(BOOL)animation;

- (void) addNewUnit:(NSString *)icon withName:(NSString *)name;
- (void) addNewUnitWithName:(NSString *)name;
- (void) addNewUnitWithName:(NSString *)name userInteractionEnabled:(BOOL)userInteractionEnabled;
- (DestinationUnit *) addUnit:(NSString *)icon withName:(NSString *)name;
- (DestinationUnit *)addUnit:(NSString *)icon withName:(NSString *)name andUnitHeight:(CGFloat)height;

/**
 *  添加一个 unit
 *
 *  @param icon
 *  @param name
 *  @param height
 *  @param userInteractionEnabled  点击是否能删除
 *  @return
 */
- (DestinationUnit *)addUnit:(NSString *)icon withName:(NSString *)name andUnitHeight:(CGFloat)height userInteractionEnabled:(BOOL)userInteractionEnabled;

- (void) reset;

- (void) removeUnitAtIndex:(NSInteger)index;

@end
