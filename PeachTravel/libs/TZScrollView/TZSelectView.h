//
//  TZSelectView.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/1/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

/**
 *  多项选择时候展示选择内容的 view的 super class，如选取目的地的时候会用到，新建聊天的时候会用到
 */
#import <UIKit/UIKit.h>

@protocol TaoziSelectViewDelegate <NSObject>

- (void)removeUintCell:(NSInteger)index;

@optional
- (void)nextStep;

@end

@interface TZSelectView : UIView

@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) id<TaoziSelectViewDelegate> delegate;

/**
 *  初始化
 *
 *  @param frame 界面的尺寸
 *  @param title 下一步的标题，若为 nil 则没有下一步标题
 *
 *  @return self
 */
- (id)initWithFrame:(CGRect)frame andNextBtnTitle:(NSString *)title;


/**
 *  添加一个外部定义好的 unit
 *
 *  @param unit 一个 view
 */
- (void)addNewUnit:(UIView *)unit;

/**
 *  删除一个 unit
 *
 *  @param index 删除的位置
 */
- (void) removeUnitAtIndex:(NSInteger)index;

/*
 *  @method
 *  @function
 *  unitCell被点击代理，需要执行删除操作
 */
- (void)unitCellTouched:(UIView *)unitCell;

/**
 *  隐藏 self
 *
 *  @param hidden
 *  @param animation
 */
-(void)setHidden:(BOOL)hidden withAnimation:(BOOL)animation;


@end
