//
//  TZFilterView.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZFilterView : UIView

/**
 *  储存选中 item 的 indexpath
 */
@property (nonatomic, strong) NSArray *selectedItmesIndex;
/**
 * 储存筛选type标题的数组
 */
@property (nonatomic, strong) NSArray *filterTitles;

/**
 *  每个分类的筛选有多少行
 */
@property (nonatomic, strong) NSArray *lineCountPerFilterType;

/**
 *  储存筛选按钮标题的数组,必须设置完其他的属性之后才能设置这个
 */
@property (nonatomic, strong) NSArray *filterItemsArray;

/**
 *  储存当前所有的筛选 item
 */
@property (nonatomic, strong, readonly) NSArray *itemsArray;

/**
 *  确定按钮
 */
@property (nonatomic, strong)  UIButton *comfirmBtn;

/**
 *  取消按钮
 */
@property (nonatomic, strong)  UIButton *cancelBtn;


@end
