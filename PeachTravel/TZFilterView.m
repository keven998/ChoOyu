//
//  TZFilterView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZFilterView.h"

@interface TZFilterView ()

@property (nonatomic, strong) UIScrollView *filterScrollView;

/**
 *  储存当前选中的 item 的 indexpath
 */
@property (nonatomic, strong) NSArray *currentSelectedArray;

@end

@implementation TZFilterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
        label.text = @"筛选";
        label.textColor = TEXT_COLOR_TITLE;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15.0];
        [self addSubview:label];
        
        _filterScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-40-50)];
        
        [self addSubview:_filterScrollView];
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, 0.5)];
        spaceView.backgroundColor = APP_DIVIDER_COLOR;
        [self addSubview:spaceView];
        
        UIView *spaceViewButtom = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-50, self.bounds.size.width, 0.5)];
        spaceViewButtom.backgroundColor = APP_DIVIDER_COLOR;
        [self addSubview:spaceViewButtom];
        
        _comfirmBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.bounds.size.width-115)/2, self.bounds.size.height-42, 115, 32)];
//        _comfirmBtn.backgroundColor = APP_THEME_COLOR;
        [_comfirmBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
        _comfirmBtn.layer.cornerRadius = 2.0;
        _comfirmBtn.clipsToBounds = YES;
        [_comfirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_comfirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_comfirmBtn];
        
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.bounds.size.width-40), 10, 30, 20)];
        [_cancelBtn setImage:[UIImage imageNamed:@"ic_filter_cancel.png"] forState:UIControlStateNormal];
        [self addSubview:_cancelBtn];

    }
    return self;
}

- (void)setFilterItemsArray:(NSArray *)filterItemsArray
{
    _filterItemsArray = filterItemsArray;
    [self setNeedsDisplay];
}

- (void)setSelectedItmesIndex:(NSArray *)selectedItmesIndex
{
    _selectedItmesIndex = selectedItmesIndex;
    for (int i=0; i<_itemsArray.count; i++) {
        NSInteger index = [[_selectedItmesIndex objectAtIndex:i] integerValue];
        NSArray *items = [_itemsArray objectAtIndex:i];
        for (int j=0; j<items.count ; j++) {
            UIButton *btn = [items objectAtIndex:j];
            if (index == j) {
                btn.selected = YES;
                btn.layer.borderWidth = 0;
            }
            if (btn.selected && j!=index) {
                btn.selected = NO;
                btn.layer.borderWidth = 1.0;
            }
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    CGFloat offsetY = 10;
    
    NSMutableArray *totalItems = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<_filterItemsArray.count; i++) {
        
        NSInteger selectedIndex = [[_selectedItmesIndex objectAtIndex:i] integerValue];
        
        NSMutableArray *totalItemsPerType = [[NSMutableArray alloc] init];
        
        NSArray *items = [_filterItemsArray objectAtIndex:i];
        NSString *title = [_filterTitles objectAtIndex:i];
        
        if (title) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, offsetY, self.bounds.size.width-20, 15)];
            titleLabel.text = title;
            titleLabel.textColor = TEXT_COLOR_TITLE;
            titleLabel.font = [UIFont systemFontOfSize:13.0];
            [_filterScrollView addSubview:titleLabel];
            offsetY += 20;
        }
        
        NSInteger lineCount = [[_lineCountPerFilterType objectAtIndex:i] integerValue];
        
        CGFloat height = lineCount*40;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, offsetY, self.bounds.size.width-20, height)];
        
        offsetY += (height+10);
        
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.tag = i;
        
        if (lineCount > 1) {
            CGFloat offsetX = 0;
            //处在第几行
            NSInteger line = 0;
            for (int j=0; j<items.count; j++) {
                NSString *itemTitle = [items objectAtIndex:j];
                
                CGSize size = [itemTitle sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:13.0]}];
                
                if (offsetX + size.width+30 > scrollView.frame.size.width) {
                    offsetX = 0;
                    line++;
                }
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 5+40*line, size.width+30, 30)];
                [btn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                [btn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateHighlighted];
                [btn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateSelected];
                btn.layer.cornerRadius = 2.0;
                btn.layer.borderColor = APP_PAGE_COLOR.CGColor;
                btn.layer.borderWidth = 1.0;
                btn.clipsToBounds = YES;
                [btn setTitle: itemTitle forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
                btn.tag = j;
                [btn addTarget:self action:@selector(choseItem:) forControlEvents:UIControlEventTouchUpInside];
                
                //默认选中第一个
                if (j == selectedIndex) {
                    btn.selected = YES;
                    btn.layer.borderWidth = 0;
                }
                [scrollView addSubview:btn];
                offsetX += (size.width+40);
                [totalItemsPerType addObject:btn];
            }
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 40*(line+1));
            
        } else {
            CGFloat offsetX = 0;
            for (int j=0; j<items.count; j++) {
                NSString *itemTitle = [items objectAtIndex:j];
                
                CGSize size = [itemTitle sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:13.0]}];
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 5, size.width+30, 30)];
                [btn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                [btn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                [btn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateHighlighted];
                [btn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateSelected];
                btn.layer.cornerRadius = 2.0;
                btn.clipsToBounds = YES;
                btn.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
                btn.layer.borderWidth = 1.0;
                [btn setTitle: itemTitle forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
                btn.tag = j;
                [btn addTarget:self action:@selector(choseItem:) forControlEvents:UIControlEventTouchUpInside]; 
                if (j == selectedIndex) {
                    btn.selected = YES;
                    btn.layer.borderWidth = 0;
                }
                [scrollView addSubview:btn];
                offsetX += (size.width+40);
                [totalItemsPerType addObject:btn];
            }
            scrollView.contentSize = CGSizeMake(offsetX, 40);
        }
        [_filterScrollView addSubview:scrollView];
        
        //如果不是最后一栏
        if (i < _filterTitles.count-1) {
            UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(10, offsetY, self.bounds.size.width-20, 0.5)];
            offsetY += 10;
            spaceView.backgroundColor = APP_DIVIDER_COLOR;
            [_filterScrollView addSubview:spaceView];
        }
        [totalItems addObject:totalItemsPerType];
    }
    [_filterScrollView setContentSize:CGSizeMake(_filterScrollView.bounds.size.width, offsetY)];
    _itemsArray = totalItems;
}

- (void)choseItem:(UIButton *)sender
{
    for (NSArray *array in _itemsArray) {
        for (UIButton *btn in array) {
            if (btn.selected && sender.superview.tag == [_itemsArray indexOfObject:array]) {
                btn.layer.borderWidth = 1.0;
                btn.selected = NO;
            }
        }
    }
    sender.selected = YES;
    sender.layer.borderWidth = 0;
}
@end
