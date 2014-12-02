//
//  TZSelectView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/1/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZSelectView.h"

@interface TZSelectView () <UIScrollViewDelegate>

{
    CGFloat offsetX;
}

#define defaultHeight  40      // 每一个unitCell的默认宽度
#define defaultPace   8       // unitCell之间的间距
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

@implementation TZSelectView

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
        self.alpha = 0.8;
        UIButton *nextBtn;
        if (title) {
            nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-70, 0, 70, frame.size.height)];
            [nextBtn setTitle:title forState:UIControlStateNormal];
            nextBtn.alpha = 0.8;
            nextBtn.backgroundColor = UIColorFromRGB(0xee528c);
            [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
            [self addSubview:nextBtn];
            
            UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, frame.size.height)];
            spaceView.backgroundColor = [UIColor whiteColor];
            [nextBtn addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
            [nextBtn addSubview:spaceView];
        }
        
        [self setPropertyWithNextBtn:nextBtn];
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
    topline.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:topline];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    if (nextBtn) {
        _scrollView.frame = CGRectMake(0, 0, self.bounds.size.width - 72, self.frame.size.height);
    } else {
        _scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.frame.size.height);
    }
    _scrollView.backgroundColor = self.backgroundColor;
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
    UIView *lastUnit = [_unitList lastObject];
    NSLog(@"最后一个%@", NSStringFromCGRect(lastUnit.frame));
    _scrollView.contentSize = CGSizeMake(lastUnit.frame.size.width + lastUnit.frame.origin.x, _scrollView.frame.size.height);
    [_scrollView scrollRectToVisible:lastUnit.frame animated:YES];
}

- (void)addNewUnit:(UIView *)unit
{
    unit.alpha = 0.1;
    CGRect frame = CGRectMake(offsetX, unit.frame.origin.y, unit.frame.size.width, unit.frame.size.height);
    [unit setFrame:frame];
    [_unitList addObject:unit];
    [_scrollView addSubview:unit];
    [self scrollViewAbleScroll];
    
    [UIView animateWithDuration:duration animations:^(){
        unit.alpha = 0.8;
    } completion:^(BOOL finished){
        unit.alpha = 1.0;
    }];
    offsetX += defaultPace + unit.frame.size.width;
}


- (void)removeUnitAtIndex:(NSInteger)index
{
    UIView *unitCell = [_unitList objectAtIndex:index];
    [self unitCellTouched:unitCell];
}

/*
 *  @method
 *  @function
 *  unitCell被点击代理，需要执行删除操作
 */
- (void)unitCellTouched:(UIView *)unitCell
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
                UIView *cell = [_unitList objectAtIndex:(NSUInteger) i];
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
                UIView *cell = [_unitList objectAtIndex:(NSUInteger)i];
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
            UIView *cell = [_unitList objectAtIndex:(NSUInteger) i];
            CGRect rect = cell.frame;
            rect.origin.x -= (defaultPace + width);
            cell.frame = rect;
        }
        
        _frontMove = NO;
        _moveCount = 0;
    }
    
    if (_hasDelete)
    {
        UIView *lastUnit = [_unitList lastObject];
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

#pragma mark - IBAction Methods

/**
 *  点击下一步按钮，调用delegate
 *
 *  @param sender
 */

- (IBAction)next:(id)sender
{
    [self.delegate nextStep];
}

@end
