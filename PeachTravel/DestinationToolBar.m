//
//  DestinationToolBar.m
//  PeachTravelDemo
//
//  Created by liangpengshuai on 14/9/24.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "DestinationToolBar.h"
#import "DestinationUnit.h"

@interface DestinationToolBar ()<UIScrollViewDelegate>
{
    CGFloat offsetX;
}

#define defaultHeight  40.0      // 每一个unitCell的默认高度
#define defaultPace   10.0       // unitCell之间的间距
#define duration      0.3     // 动画执行时间
#define defaultVisibleCount 3 //默认显示的unitCell的个数

/*
 @abstract 用于显示成员
 */


/*
 @abstract 用于管理成员
 */
@property (nonatomic, strong) NSMutableArray *unitList;

/*
 @abstract 判断是否有删除操作
 */
@property (nonatomic, assign) BOOL           hasDelete;

/*
 @abstract 判断删除操作unitCell的移动方向
 */
@property (nonatomic, assign) BOOL           frontMove;

/*
 @abstract 统计删除操作总共移动的次数
 */
@property (nonatomic, assign) int            moveCount;

@end

@implementation DestinationToolBar

/**
 *  初始化一个带下一步按钮的界面
 *
 *  @param frame  view 的尺寸
 *  @param title 下一步按钮的名字
 *
 *  @return  self
 */
- (id)initWithFrame:(CGRect)frame andNextBtnTitle:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        offsetX = defaultPace;
        self.backgroundColor = UIColorFromRGB(0xee528c);
        self.alpha = 0.8;
        if (title) {
            _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-70, 0, 70, frame.size.height)];
            [_nextBtn setTitle:title forState:UIControlStateNormal];
            _nextBtn.alpha = 0.8;
            _nextBtn.backgroundColor = UIColorFromRGB(0xee528c);
            [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
            [self addSubview:_nextBtn];
            
            UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, frame.size.height)];
            spaceView.backgroundColor = [UIColor whiteColor];
            [_nextBtn addSubview:spaceView];
        }
        
        [self setPropertyWithNextBtn:_nextBtn];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andNextBtnTitle:nil];
}

/*
 *   @method
 *   @function
 *   初始化_scrollView等
 */
- (void) setPropertyWithNextBtn:(UIButton *)nextBtn
{
    _unitList = [[NSMutableArray alloc] init];
    _hasDelete = NO;
    _moveCount = 0;
    
    UILabel *topline = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
    topline.backgroundColor = APP_PAGE_COLOR;
    [self addSubview:topline];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    if (nextBtn) {
        _scrollView.frame = CGRectMake(0, (self.bounds.size.height - defaultHeight)/2.0, self.bounds.size.width - 72, defaultHeight);
    } else {
        _scrollView.frame = CGRectMake(0, (self.bounds.size.height - defaultHeight)/2.0, self.bounds.size.width, defaultHeight);
    }
    _scrollView.alpha = 0.8;
    _scrollView.scrollEnabled = YES;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    [self addSubview:_scrollView];
    
    [self scrollViewAbleScroll];
}

/*
 *  @method
 *  @function
 *  根据_unitList.count
 *  设置scrollView是否可以滚动
 *  设置scrollView的ContentSize
 *  设置scrollView的VisibleRect
 */
- (void)scrollViewAbleScroll
{
    DestinationUnit *lastUnit = [_unitList lastObject];
    NSLog(@"最后一个%@", NSStringFromCGRect(lastUnit.frame));
    _scrollView.contentSize = CGSizeMake(lastUnit.frame.size.width + lastUnit.frame.origin.x, _scrollView.frame.size.height);
    [_scrollView scrollRectToVisible:lastUnit.frame animated:YES];
}

/*
 *  @method
 *  @function
 *  新增一个unitCell
 *  _defaultUnit向后移动并伴随动画效果
 *  newUnitCell渐变显示
 */
- (void) addNewUnit:(NSString *)icon withName:(NSString *)name
{
    __block DestinationUnit *newUnitCell;
    
    if (icon) {
        newUnitCell = [[DestinationUnit alloc] initWithFrame:CGRectMake(offsetX, 5, 0, defaultHeight) andIcon:icon andName:name];
    } else {
        newUnitCell = [[DestinationUnit alloc] initWithFrame:CGRectMake(offsetX, 5, 0, defaultHeight) andName:name];
    }
    offsetX += defaultPace+newUnitCell.frame.size.width;
    newUnitCell.alpha = 0.1;
    [newUnitCell addTarget:self action:@selector(unitCellTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_unitList addObject:newUnitCell];
    [_scrollView addSubview:newUnitCell];
    [self scrollViewAbleScroll];
    
    [UIView animateWithDuration:duration animations:^(){
        newUnitCell.alpha = 0.8;
    } completion:^(BOOL finished){
        newUnitCell.alpha = 1.0;
    }];
}

/*
 *  @method
 *  @function
 *  新增一个unitCell
 *  _defaultUnit向后移动并伴随动画效果
 *  newUnitCell渐变显示
 */
- (void) addNewUnit:(NSString *)icon withName:(NSString *)name userInteractionEnabled:(BOOL)userInteractionEnabled
{
    __block DestinationUnit *newUnitCell;
    
    if (icon) {
        newUnitCell = [[DestinationUnit alloc] initWithFrame:CGRectMake(offsetX, 5, 0, defaultHeight) andIcon:icon andName:name];
    } else {
        newUnitCell = [[DestinationUnit alloc] initWithFrame:CGRectMake(offsetX, 5, 0, defaultHeight) andName:name];
    }
    offsetX += defaultPace+newUnitCell.frame.size.width;
    newUnitCell.alpha = 0.1;
    if (userInteractionEnabled) {
        [newUnitCell addTarget:self action:@selector(unitCellTouched:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        newUnitCell.userInteractionEnabled = NO;
    }
    [_unitList addObject:newUnitCell];
    [_scrollView addSubview:newUnitCell];
    [self scrollViewAbleScroll];
    
    [UIView animateWithDuration:duration animations:^(){
        newUnitCell.alpha = 0.8;
    } completion:^(BOOL finished){
        newUnitCell.alpha = 1.0;
    }];
}

- (DestinationUnit *)addUnit:(NSString *)icon withName:(NSString *)name
{
    return [self addUnit:icon withName:name andUnitHeight:defaultHeight];
   
}

- (DestinationUnit *)addUnit:(NSString *)icon withName:(NSString *)name andUnitHeight:(CGFloat)height userInteractionEnabled:(BOOL)userInteractionEnabled
{
    __block DestinationUnit *newUnitCell;
    
    if (icon) {
        newUnitCell = [[DestinationUnit alloc] initWithFrame:CGRectMake(offsetX, (self.scrollView.frame.size.height-height)/2, 0, height) andIcon:icon andName:name];
    } else {
        newUnitCell = [[DestinationUnit alloc] initWithFrame:CGRectMake(offsetX, (self.scrollView.frame.size.height-height)/2, 0, height) andName:name];
    }
    
    if (userInteractionEnabled) {
        [newUnitCell addTarget:self action:@selector(unitCellTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    offsetX += defaultPace+newUnitCell.frame.size.width;
    newUnitCell.alpha = 0.1;
    [_unitList addObject:newUnitCell];
    [_scrollView addSubview:newUnitCell];
    [self scrollViewAbleScroll];
    
    [UIView animateWithDuration:duration animations:^(){
        newUnitCell.alpha = 0.8;
    } completion:^(BOOL finished){
        newUnitCell.alpha = 1.0;
    }];
    return newUnitCell;
}

- (DestinationUnit *)addUnit:(NSString *)icon withName:(NSString *)name andUnitHeight:(CGFloat)height
{
    return [self addUnit:icon withName:name andUnitHeight:height userInteractionEnabled:YES];
}


/*
 *  @method
 *  @function
 *  新增一个unitCell
 *  _defaultUnit向后移动并伴随动画效果
 *  newUnitCell渐变显示
 */
- (void)addNewUnitWithName:(NSString *)name
{
    [self addNewUnit:nil withName:name];
}

/**
 *  新增一个unitCell
 *
 *  @param name          新增按钮的标题
 *  @param userInterface 是否禁止用户点击操作，yes 是不禁止，no 是禁止
 */
- (void) addNewUnitWithName:(NSString *)name userInteractionEnabled:(BOOL)userInteractionEnabled
{
    [self addNewUnit:nil withName:name userInteractionEnabled:userInteractionEnabled];
}


- (void)removeUnitAtIndex:(NSInteger)index
{
    DestinationUnit *unitCell = [_unitList objectAtIndex:index];
    [self unitCellTouched:unitCell];
}

/*
 *  @method
 *  @function
 *  unitCell被点击代理，需要执行删除操作
 */
- (void)unitCellTouched:(UIButton *)unitCell
{
    _hasDelete = YES;
    __block int index = (int)[_unitList indexOfObject:unitCell];
    
    // step_1: 设置相关unitCell的透明度
    unitCell.alpha = 0.8;
    
    // 判断其余cell的移动方向（从前向后移动/从后向前移动）
    _frontMove = NO;
    if (_unitList.count - 1 > defaultVisibleCount && (_unitList.count - index - 1) <= defaultVisibleCount) {
        _frontMove = YES;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(removeUintCell:)]) {
        [_delegate removeUintCell:index];
    }
    
    [UIView animateWithDuration:duration animations:^(){
        
        // step_2: 其余unitCell依次移动
        if (_frontMove)
        {
            // 前面的向后移动
            for (int i = 0; i < index; i++) {
                DestinationUnit *cell = [_unitList objectAtIndex:(NSUInteger) i];
                CGRect rect = cell.frame;
                rect.origin.x += (defaultPace + unitCell.frame.size.width);
                cell.frame = rect;
            }
            _moveCount++;
        }
        else
        {
            // 后面的向前移动
            for (int i = index + 1; i < _unitList.count; i++) {
                DestinationUnit *cell = [_unitList objectAtIndex:(NSUInteger)i];
                CGRect rect = cell.frame;
                rect.origin.x -= (defaultPace + unitCell.frame.size.width);
                cell.frame = rect;
            }
        }
        unitCell.alpha = 0.0;
        
    } completion:^(BOOL finished){
        
        // step_4: 删除被点击的unitCell
        offsetX -= (unitCell.frame.size.width + defaultPace);
        [unitCell removeFromSuperview];
        [_unitList removeObject:unitCell];
        if (offsetX < _scrollView.frame.size.width)
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        if (_frontMove) {
            [self isNeedResetFrameWithWidth:unitCell.frame.size.width];
        }
    }];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //    [self isNeedResetFrame];
}

/*
 *  @method
 *  @function
 *  当删除操作是前面的unitCell向后移动时
 *  做滚动操作或者添加操作需要重新设置每个unitCell的frame
 */
- (void)isNeedResetFrameWithWidth:(CGFloat)width
{
    if (_frontMove && _moveCount > 0) {
        
        for (int i = 0; i < _unitList.count; i++) {
            DestinationUnit *cell = [_unitList objectAtIndex:(NSUInteger) i];
            CGRect rect = cell.frame;
            rect.origin.x -= (defaultPace + width);
            cell.frame = rect;
        }
        
        _frontMove = NO;
        _moveCount = 0;
    }
    
    if (_hasDelete)
    {
        DestinationUnit *lastUnit = [_unitList lastObject];
        _scrollView.contentSize = CGSizeMake(lastUnit.frame.size.width + lastUnit.frame.origin.x, _scrollView.frame.size.height);
        _hasDelete = !_hasDelete;
    }
}

-(void)setHidden:(BOOL)hidden withAnimation:(BOOL)animation
{
    if (animation) {
        [self setHidden:hidden];
    } else {
        [self animationStop];
    }
}

-(void)setHidden:(BOOL)hidden
{
    if (hidden) {
        //隐藏时
        self.alpha= 1.0f;
        [UIView beginAnimations:@"fadeOut" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelegate:self];//设置委托
        [UIView setAnimationDidStopSelector:@selector(animationStop)];//当动画结束时，我们还需要再将其隐藏
        self.alpha = 0.0f;
        [UIView commitAnimations];
    }
    else
    {
        self.alpha= 0.0f;
        [super setHidden:hidden];
        [UIView beginAnimations:@"fadeIn" context:nil];
        [UIView setAnimationDuration:0.4];
        self.alpha= 1.0f;
        [UIView commitAnimations];
    }
}

-(void)animationStop
{
    [super setHidden:!self.hidden];
}


@end






